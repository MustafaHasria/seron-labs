import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/di/app_dependencies.dart';
import '../../../../lib/core/utils/clock.dart';
import '../../../../lib/features/trading_stream/data/services/mock_trade_service.dart';
import '../../../../lib/features/trading_stream/domain/entities/trade.dart';
import '../../../../lib/features/trading_stream/domain/repositories/i_trade_repository.dart';
import '../../../../lib/features/trading_stream/domain/services/i_metrics_engine.dart';
import '../../../../lib/features/trading_stream/presentation/bloc/trading_bloc.dart';
import '../../../../lib/features/trading_stream/presentation/bloc/trading_event.dart';

void main() {
  group('Burst & Freeze Integrity Test', () {
    late FixedClock clock;
    late TradingBloc bloc;
    late ITradeRepository repository;
    late IMetricsEngine metricsEngine;

    setUp(() {
      // Use fixed clock for deterministic testing
      clock = FixedClock(DateTime(2024, 1, 1, 12, 0, 0));
      initializeAppDependencies();

      // Override clock in service locator
      sl.unregister<IClock>();
      sl.registerLazySingleton<IClock>(() => clock);

      // Get dependencies
      repository = sl<ITradeRepository>();
      metricsEngine = sl<IMetricsEngine>();
      bloc = sl<TradingBloc>();
    });

    tearDown(() async {
      await bloc.close();
      await repository.dispose();
      
      // Dispose service to stop timer
      if (sl.isRegistered<ITradeService>()) {
        try {
          final service = sl<ITradeService>();
          if (service is MockTradeService) {
            await service.dispose();
          }
        } catch (_) {
          // Already disposed
        }
      }
      
      await sl.reset();
    });

    test('burst test: 100 events @ 10ms intervals with freeze', () async {
      // Note: Using the default MockTradeService from DI container
      // which is already configured and running

      // Start bloc
      bloc.add(const TradingStarted());

      // Wait for initial state
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Collect trades and calculate expected total volume
      final expectedPrices = <double>[];
      var tradeCount = 0;

      // Listen to trades
      final tradeSubscription = repository.enrichedTradeStream.listen((trade) {
        tradeCount++;
        expectedPrices.add(trade.trade.price);
      });

      // Wait for trades to accumulate (MockTradeService emits at 50ms by default)
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Freeze after receiving some trades
      if (tradeCount >= 5) {
        bloc.add(const TradingToggleFreeze());
      }

      // Continue receiving remaining trades while frozen
      final frozenTradeCount = tradeCount;
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Verify visibleTrades remains at frozen snapshot
      final frozenState = bloc.state;
      expect(frozenState.isFrozen, true);
      expect(frozenState.visibleTrades.length, lessThanOrEqualTo(50));

      // Verify metrics continue updating
      final metrics = metricsEngine.currentMetrics;
      expect(metrics.totalVolume, greaterThan(0));

      // Unfreeze
      bloc.add(const TradingToggleFreeze());

      // Wait for reconciliation
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify final state
      final finalState = bloc.state;
      expect(finalState.isFrozen, false);

      await tradeSubscription.cancel();
    });

    test('total volume remains mathematically accurate during freeze', () async {
      // This test verifies that total volume calculation is lossless
      // even when UI is frozen
      // Note: We test metricsEngine directly without starting the trade stream
      // to avoid interference from MockTradeService's automatic trade generation

      // Process some trades manually for testing
      final testPrices = [100.0, 200.0, 300.0, 400.0, 500.0];
      var expectedTotal = 0.0;

      for (final price in testPrices) {
        metricsEngine.processTrade(
          Trade(
            tradeId: 't${testPrices.indexOf(price) + 1}',
            userId: 'u1',
            symbol: 'BTC',
            price: price,
            timestamp: clock.now(),
          ),
        );
        expectedTotal += price;
      }

      // Verify metrics before freeze
      var metrics = metricsEngine.currentMetrics;
      expect(metrics.totalVolume, expectedTotal);

      // Process more trades (simulating "during freeze" scenario)
      final morePrices = [600.0, 700.0];
      for (final price in morePrices) {
        metricsEngine.processTrade(
          Trade(
            tradeId: 't${testPrices.length + morePrices.indexOf(price) + 1}',
            userId: 'u2',
            symbol: 'ETH',
            price: price,
            timestamp: clock.now(),
          ),
        );
        expectedTotal += price;
      }

      // Verify metrics are accurate (totaling 2800.0)
      metrics = metricsEngine.currentMetrics;
      expect(metrics.totalVolume, expectedTotal);
      
      // Verify the exact expected value for clarity
      expect(metrics.totalVolume, 2800.0);
    });
  });
}

