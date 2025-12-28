import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../../../../lib/core/di/app_dependencies.dart';
import '../../../../../lib/core/theme/app_theme.dart';
import '../../../../../lib/core/utils/clock.dart';
import '../../../../../lib/features/trading_stream/domain/entities/enriched_trade.dart';
import '../../../../../lib/features/trading_stream/domain/entities/trade.dart';
import '../../../../../lib/features/trading_stream/domain/entities/user_reputation.dart';
import '../../../../../lib/features/trading_stream/presentation/widgets/trade_tile.dart';
import '../../../../../lib/features/trading_stream/presentation/widgets/trade_tile_adapter.dart';

/// Mock implementation of ITradeTileData for testing.
class MockTradeTileData implements ITradeTileData {
  @override
  final String primaryLabel;
  @override
  final String secondaryLabel;
  @override
  final String tertiaryLabel;
  @override
  final TradeTileState state;
  @override
  final List<double> sparklineData;
  @override
  final VoidCallback? onRetry;

  MockTradeTileData({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.state,
    required this.sparklineData,
    this.onRetry,
  });

  factory MockTradeTileData.loading() {
    return MockTradeTileData(
      primaryLabel: 'BTC',
      secondaryLabel: '\$45,000.00',
      tertiaryLabel: '',
      state: TradeTileState.loading,
      sparklineData: [45000, 45100, 45050, 45150, 45200],
    );
  }

  factory MockTradeTileData.success() {
    return MockTradeTileData(
      primaryLabel: 'ETH',
      secondaryLabel: '\$2,500.00',
      tertiaryLabel: 'Rep:85',
      state: TradeTileState.success,
      sparklineData: [2500, 2510, 2505, 2520, 2515, 2530, 2525, 2540, 2535, 2550],
    );
  }

  factory MockTradeTileData.error() {
    return MockTradeTileData(
      primaryLabel: 'SOL',
      secondaryLabel: '\$90.00',
      tertiaryLabel: '',
      state: TradeTileState.error,
      sparklineData: [90, 91, 90.5, 92, 91.5],
      onRetry: () {},
    );
  }

  factory MockTradeTileData.stale() {
    return MockTradeTileData(
      primaryLabel: 'XRP',
      secondaryLabel: '\$0.55',
      tertiaryLabel: 'Rep:42',
      state: TradeTileState.stale,
      sparklineData: [0.55, 0.56, 0.55, 0.57, 0.56],
    );
  }
}

void main() {
  group('TradeTile Golden Tests', () {
    setUpAll(() async {
      await loadAppFonts();
    });

    testGoldens('TradeTile loading state', (tester) async {
      await tester.pumpWidgetBuilder(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TradeTile(
              data: MockTradeTileData.loading(),
            ),
          ),
        ),
        surfaceSize: const Size(400, 80),
      );

      await screenMatchesGolden(tester, 'trade_tile_loading');
    });

    testGoldens('TradeTile success state', (tester) async {
      await tester.pumpWidgetBuilder(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TradeTile(
              data: MockTradeTileData.success(),
            ),
          ),
        ),
        surfaceSize: const Size(400, 80),
      );

      await screenMatchesGolden(tester, 'trade_tile_success');
    });

    testGoldens('TradeTile error state', (tester) async {
      await tester.pumpWidgetBuilder(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TradeTile(
              data: MockTradeTileData.error(),
            ),
          ),
        ),
        surfaceSize: const Size(400, 120),
      );

      await screenMatchesGolden(tester, 'trade_tile_error');
    });

    testGoldens('TradeTile stale state', (tester) async {
      await tester.pumpWidgetBuilder(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TradeTile(
              data: MockTradeTileData.stale(),
            ),
          ),
        ),
        surfaceSize: const Size(400, 80),
      );

      await screenMatchesGolden(tester, 'trade_tile_stale');
    });

    testGoldens('TradeTile with adapter - stale based on clock', (tester) async {
      // Create stale trade (3+ seconds old)
      final clock = FixedClock(DateTime(2024, 1, 1, 12, 0, 5));
      final staleTrade = EnrichedTrade(
        trade: Trade(
          tradeId: 't1',
          userId: 'u1',
          symbol: 'BTC',
          price: 45000.0,
          timestamp: DateTime(2024, 1, 1, 12, 0, 0), // 5 seconds ago
        ),
        reputation: const UserReputation.stale(),
      );

      await tester.pumpWidgetBuilder(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TradeTile(
              data: TradeTileAdapter(
                enrichedTrade: staleTrade,
                sparklineData: [45000, 45100, 45050],
              ),
            ),
          ),
        ),
        surfaceSize: const Size(400, 80),
      );

      await screenMatchesGolden(tester, 'trade_tile_stale_clock');
    });
  });
}

