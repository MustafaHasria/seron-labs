import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/page_state.dart';
import '../../domain/entities/enriched_trade.dart';
import '../../domain/entities/trade.dart';
import '../../domain/entities/trade_metrics.dart';
import '../../domain/entities/user_reputation.dart';
import '../../domain/repositories/i_trade_repository.dart';
import '../../domain/services/i_metrics_engine.dart';
import 'trading_event.dart';
import 'trading_state.dart';

/// Trading BLoC - manages trade stream and freeze/unfreeze reconciliation.
class TradingBloc extends Bloc<TradingEvent, TradingState> {
  final ITradeRepository _repository;
  final IMetricsEngine _metricsEngine;

  StreamSubscription? _tradeSubscription;
  StreamSubscription? _metricsSubscription;

  // Buffer for trades received while frozen
  final List<Trade> _bufferedTrades = [];

  // Sparkline history: last 10 trades per symbol
  final Map<String, List<double>> _sparklineHistory = {};
  static const int _sparklineSize = 10;

  TradingBloc({required ITradeRepository repository, required IMetricsEngine metricsEngine})
    : _repository = repository,
      _metricsEngine = metricsEngine,
      super(TradingState(metrics: TradeMetrics(totalVolume: 0.0, rollingAverage: 0.0, assetDistribution: {}))) {
    on<TradingStarted>(_onStarted);
    on<TradingTradeReceived>(_onTradeReceived);
    on<TradingMetricsUpdated>(_onMetricsUpdated);
    on<TradingToggleFreeze>(_onToggleFreeze);
    on<TradingJumpToLatest>(_onJumpToLatest);
    on<TradingRetryMetadata>(_onRetryMetadata);
  }

  Future<void> _onStarted(TradingStarted event, Emitter<TradingState> emit) async {
    // Subscribe to enriched trade stream
    _tradeSubscription = _repository.enrichedTradeStream.listen((trade) {
      add(TradingTradeReceived(trade));
    });

    // Subscribe to metrics stream
    _metricsSubscription = _metricsEngine.metricsStream.listen((metrics) {
      add(TradingMetricsUpdated(metrics));
    });

    emit(state.copyWith(pageState: PageState.success));
  }

  void _onTradeReceived(TradingTradeReceived event, Emitter<TradingState> emit) {
    final trade = event.trade;

    // Always process trade for metrics (domain continues)
    _metricsEngine.processTrade(trade.trade);

    // Update sparkline history
    final symbol = trade.trade.symbol;
    final history = _sparklineHistory[symbol] ?? [];
    history.add(trade.trade.price);
    if (history.length > _sparklineSize) {
      history.removeAt(0);
    }
    _sparklineHistory[symbol] = history;

    if (state.isFrozen) {
      // Accumulate in buffer, don't update visibleTrades
      _bufferedTrades.add(trade.trade);
      emit(
        state.copyWith(
          deltaCount: state.deltaCount + 1,
          sparklineData: Map.from(_sparklineHistory),
          // Keep showing frozen snapshot
          visibleTrades: state.frozenSnapshot,
        ),
      );
    } else {
      // Update visible trades (max 50)
      final updated = [trade, ...state.visibleTrades].take(50).toList();
      emit(state.copyWith(visibleTrades: updated, sparklineData: Map.from(_sparklineHistory)));
    }
  }

  void _onMetricsUpdated(TradingMetricsUpdated event, Emitter<TradingState> emit) {
    // Metrics always update, even when frozen
    emit(state.copyWith(metrics: event.metrics));
  }

  void _onToggleFreeze(TradingToggleFreeze event, Emitter<TradingState> emit) {
    if (state.isFrozen) {
      // Unfreezing
      final deltaCount = state.deltaCount;
      if (deltaCount > 50) {
        // Show banner, don't update list yet (keep buffer for JumpToLatest)
        emit(
          state.copyWith(
            isFrozen: false,
            showJumpBanner: true,
            deltaCount: 0,
            // Keep showing frozen snapshot until user clicks "Jump to Latest"
            visibleTrades: state.frozenSnapshot,
          ),
        );
        // Don't clear buffer - needed for JumpToLatest
      } else {
        // Animate deltaCount trades into list
        final newTrades = _bufferedTrades
            .take(deltaCount)
            .map((t) => EnrichedTrade(trade: t, reputation: const UserReputation.loading()))
            .toList();
        final updated = [...newTrades, ...state.visibleTrades].take(50).toList();
        emit(state.copyWith(isFrozen: false, visibleTrades: updated, deltaCount: 0, showJumpBanner: false));
        _bufferedTrades.clear();
      }
    } else {
      // Freezing
      emit(state.copyWith(isFrozen: true, frozenSnapshot: List.from(state.visibleTrades), deltaCount: 0));
      _bufferedTrades.clear();
    }
  }

  void _onJumpToLatest(TradingJumpToLatest event, Emitter<TradingState> emit) {
    // Replace with latest 50 trades from buffer
    // Note: Buffer contains trades received while frozen, in order received
    // We want the most recent 50, so take last 50 from buffer
    final bufferSize = _bufferedTrades.length;
    final startIndex = bufferSize > 50 ? bufferSize - 50 : 0;
    final latestTrades = _bufferedTrades
        .skip(startIndex)
        .take(50)
        .map((t) => EnrichedTrade(trade: t, reputation: const UserReputation.loading()))
        .toList();
    emit(state.copyWith(visibleTrades: latestTrades, showJumpBanner: false));
    _bufferedTrades.clear();
  }

  Future<void> _onRetryMetadata(TradingRetryMetadata event, Emitter<TradingState> emit) async {
    await _repository.retryMetadataFetch(event.userId);
  }

  @override
  Future<void> close() async {
    await _tradeSubscription?.cancel();
    await _metricsSubscription?.cancel();
    await _repository.dispose();
    return super.close();
  }
}
