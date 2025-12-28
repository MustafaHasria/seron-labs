import 'package:equatable/equatable.dart';

import '../../domain/entities/enriched_trade.dart';
import '../../domain/entities/trade_metrics.dart';

/// Trading BLoC events.
sealed class TradingEvent extends Equatable {
  const TradingEvent();

  @override
  List<Object?> get props => [];
}

/// Start trading stream.
final class TradingStarted extends TradingEvent {
  const TradingStarted();
}

/// Trade received from repository.
final class TradingTradeReceived extends TradingEvent {
  final EnrichedTrade trade;

  const TradingTradeReceived(this.trade);

  @override
  List<Object?> get props => [trade];
}

/// Metrics updated.
final class TradingMetricsUpdated extends TradingEvent {
  final TradeMetrics metrics;

  const TradingMetricsUpdated(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

/// Toggle freeze/unfreeze mode.
final class TradingToggleFreeze extends TradingEvent {
  const TradingToggleFreeze();
}

/// Jump to latest trades (when deltaCount > 50).
final class TradingJumpToLatest extends TradingEvent {
  const TradingJumpToLatest();
}

/// Retry metadata fetch for a userId.
final class TradingRetryMetadata extends TradingEvent {
  final String userId;

  const TradingRetryMetadata(this.userId);

  @override
  List<Object?> get props => [userId];
}

