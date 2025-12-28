import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/core/utils/clock.dart';
import '../../../../../lib/features/trading_stream/data/services/metrics_engine_impl.dart';
import '../../../../../lib/features/trading_stream/domain/entities/trade.dart';

void main() {
  group('MetricsEngineImpl - Rolling Average', () {
    late FixedClock clock;
    late MetricsEngineImpl engine;

    setUp(() {
      clock = FixedClock(DateTime(2024, 1, 1));
      engine = MetricsEngineImpl(clock: clock);
    });

    tearDown(() {
      engine.dispose();
    });

    test('empty state - no trades', () {
      final metrics = engine.currentMetrics;
      expect(metrics.rollingAverage, 0.0);
      expect(metrics.totalVolume, 0.0);
      expect(metrics.assetDistribution, isEmpty);
    });

    test('less than 50 trades - average over available', () {
      for (var i = 1; i <= 10; i++) {
        engine.processTrade(Trade(
          tradeId: 't$i',
          userId: 'u1',
          symbol: 'BTC',
          price: i * 10.0,
          timestamp: clock.now(),
        ));
      }

      final metrics = engine.currentMetrics;
      // Average of 10, 20, 30, ..., 100 = 55.0
      expect(metrics.rollingAverage, 55.0);
      expect(metrics.totalVolume, 550.0);
    });

    test('exactly 50 trades', () {
      for (var i = 1; i <= 50; i++) {
        engine.processTrade(Trade(
          tradeId: 't$i',
          userId: 'u1',
          symbol: 'BTC',
          price: i * 10.0,
          timestamp: clock.now(),
        ));
      }

      final metrics = engine.currentMetrics;
      // Average of 10, 20, 30, ..., 500 = 255.0
      expect(metrics.rollingAverage, 255.0);
      expect(metrics.totalVolume, 12750.0); // Sum of 10+20+...+500
    });

    test('more than 50 trades - rolling window', () {
      // Add 50 trades
      for (var i = 1; i <= 50; i++) {
        engine.processTrade(Trade(
          tradeId: 't$i',
          userId: 'u1',
          symbol: 'BTC',
          price: 100.0,
          timestamp: clock.now(),
        ));
      }

      // Add 10 more trades with different price
      for (var i = 51; i <= 60; i++) {
        engine.processTrade(Trade(
          tradeId: 't$i',
          userId: 'u1',
          symbol: 'BTC',
          price: 200.0,
          timestamp: clock.now(),
        ));
      }

      final metrics = engine.currentMetrics;
      // Should only have last 50 trades: 40 trades @ 100.0 + 10 trades @ 200.0
      // Average = (40 * 100 + 10 * 200) / 50 = 120.0
      expect(metrics.rollingAverage, 120.0);
    });

    test('oldest trade drops off correctly', () {
      // Add 50 trades @ 100.0
      for (var i = 1; i <= 50; i++) {
        engine.processTrade(Trade(
          tradeId: 't$i',
          userId: 'u1',
          symbol: 'BTC',
          price: 100.0,
          timestamp: clock.now(),
        ));
      }

      // Add one trade @ 500.0 (should replace oldest)
      engine.processTrade(Trade(
        tradeId: 't51',
        userId: 'u1',
        symbol: 'BTC',
        price: 500.0,
        timestamp: clock.now(),
      ));

      final metrics = engine.currentMetrics;
      // Last 50: 49 trades @ 100.0 + 1 trade @ 500.0
      // Average = (49 * 100 + 500) / 50 = 108.0
      expect(metrics.rollingAverage, 108.0);
    });

    test('asset distribution calculation', () {
      engine.processTrade(Trade(
        tradeId: 't1',
        userId: 'u1',
        symbol: 'BTC',
        price: 100.0,
        timestamp: clock.now(),
      ));

      engine.processTrade(Trade(
        tradeId: 't2',
        userId: 'u2',
        symbol: 'ETH',
        price: 200.0,
        timestamp: clock.now(),
      ));

      engine.processTrade(Trade(
        tradeId: 't3',
        userId: 'u3',
        symbol: 'BTC',
        price: 300.0,
        timestamp: clock.now(),
      ));

      final metrics = engine.currentMetrics;
      // Total volume: 600.0
      // BTC: 400.0 / 600.0 = 0.666...
      // ETH: 200.0 / 600.0 = 0.333...
      expect(metrics.totalVolume, 600.0);
      expect(metrics.assetDistribution['BTC'], closeTo(0.6667, 0.0001));
      expect(metrics.assetDistribution['ETH'], closeTo(0.3333, 0.0001));
    });
  });
}

