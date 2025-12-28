import 'dart:ui';

import '../../domain/entities/enriched_trade.dart';
import '../../domain/entities/user_reputation.dart';
import 'trade_tile.dart';

/// Adapter to convert EnrichedTrade to ITradeTileData.
class TradeTileAdapter implements ITradeTileData {
  final EnrichedTrade enrichedTrade;
  final List<double> sparklineData;
  final VoidCallback? onRetry;

  TradeTileAdapter({required this.enrichedTrade, required this.sparklineData, this.onRetry});

  @override
  String get primaryLabel => enrichedTrade.trade.symbol;

  @override
  String get secondaryLabel => '\$${enrichedTrade.trade.price.toStringAsFixed(2)}';

  @override
  String get tertiaryLabel {
    final rep = enrichedTrade.reputation;
    return switch (rep) {
      SuccessReputation(:final reputation) => reputation,
      _ => '',
    };
  }

  @override
  TradeTileState get state {
    final rep = enrichedTrade.reputation;
    return switch (rep) {
      LoadingReputation() => TradeTileState.loading,
      SuccessReputation() => TradeTileState.success,
      ErrorReputation() => TradeTileState.error,
      StaleReputation() => TradeTileState.stale,
    };
  }
}
