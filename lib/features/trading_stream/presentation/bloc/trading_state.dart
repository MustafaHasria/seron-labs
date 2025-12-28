import 'package:equatable/equatable.dart';

import '../../../../core/utils/page_state.dart';
import '../../domain/entities/enriched_trade.dart';
import '../../domain/entities/trade_metrics.dart';

/// Trading BLoC state.
class TradingState extends Equatable {
  /// Visible trades (max 50, virtualized).
  final List<EnrichedTrade> visibleTrades;

  /// Current metrics.
  final TradeMetrics metrics;

  /// Whether UI is frozen.
  final bool isFrozen;

  /// Frozen snapshot of trades.
  final List<EnrichedTrade> frozenSnapshot;

  /// Number of trades received while frozen.
  final int deltaCount;

  /// Page state.
  final PageState pageState;

  /// Show jump to latest banner.
  final bool showJumpBanner;

  /// Sparkline data per symbol (last 10 trades).
  final Map<String, List<double>> sparklineData;

  const TradingState({
    this.visibleTrades = const [],
    required this.metrics,
    this.isFrozen = false,
    this.frozenSnapshot = const [],
    this.deltaCount = 0,
    this.pageState = PageState.loading,
    this.showJumpBanner = false,
    this.sparklineData = const {},
  });

  TradingState copyWith({
    List<EnrichedTrade>? visibleTrades,
    TradeMetrics? metrics,
    bool? isFrozen,
    List<EnrichedTrade>? frozenSnapshot,
    int? deltaCount,
    PageState? pageState,
    bool? showJumpBanner,
    Map<String, List<double>>? sparklineData,
  }) {
    return TradingState(
      visibleTrades: visibleTrades ?? this.visibleTrades,
      metrics: metrics ?? this.metrics,
      isFrozen: isFrozen ?? this.isFrozen,
      frozenSnapshot: frozenSnapshot ?? this.frozenSnapshot,
      deltaCount: deltaCount ?? this.deltaCount,
      pageState: pageState ?? this.pageState,
      showJumpBanner: showJumpBanner ?? this.showJumpBanner,
      sparklineData: sparklineData ?? this.sparklineData,
    );
  }

  @override
  List<Object?> get props => [
    visibleTrades,
    metrics,
    isFrozen,
    frozenSnapshot,
    deltaCount,
    pageState,
    showJumpBanner,
    sparklineData,
  ];
}
