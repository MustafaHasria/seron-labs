import 'dart:async';

import '../../../../core/utils/clock.dart';
import '../../domain/entities/enriched_trade.dart';
import '../../domain/entities/trade.dart';
import '../../domain/entities/user_reputation.dart';
import '../../domain/repositories/i_trade_repository.dart';
import '../services/lru_cache.dart';
import '../services/mock_trade_service.dart';
import '../services/retry_strategy.dart';

/// Trade repository implementation - core synchronization engine.
class TradeRepositoryImpl implements ITradeRepository {
  final ITradeService _tradeService;
  final LRUCache<String, String> _cache;
  final RetryStrategy _retryStrategy;
  final IClock _clock;
  final StreamController<EnrichedTrade> _enrichedController;
  StreamSubscription<TradeRawData>? _tradeSubscription;

  // Track active requests to discard late results
  final Map<String, int> _activeRequestIds = {};
  int _requestCounter = 0;

  // Stale threshold: 3 seconds
  static const _staleThreshold = Duration(seconds: 3);

  TradeRepositoryImpl({
    required ITradeService tradeService,
    required LRUCache<String, String> cache,
    required RetryStrategy retryStrategy,
    required IClock clock,
  }) : _tradeService = tradeService,
       _cache = cache,
       _retryStrategy = retryStrategy,
       _clock = clock,
       _enrichedController = StreamController<EnrichedTrade>.broadcast() {
    _initialize();
  }

  void _initialize() {
    _tradeSubscription = _tradeService.tradeStream.listen((rawTrade) async {
      final trade = Trade(
        tradeId: rawTrade.tradeId,
        userId: rawTrade.userId,
        symbol: rawTrade.symbol,
        price: rawTrade.price,
        timestamp: rawTrade.timestamp,
      );

      // Immediately emit with loading state
      final enrichedTrade = EnrichedTrade(trade: trade, reputation: const UserReputation.loading());
      _enrichedController.add(enrichedTrade);

      // Check if stale
      final now = _clock.now();
      final age = now.difference(trade.timestamp);
      if (age > _staleThreshold) {
        final staleTrade = enrichedTrade.copyWith(reputation: const UserReputation.stale());
        _enrichedController.add(staleTrade);
        return;
      }

      // Check cache
      final cachedReputation = _cache.get(trade.userId);
      if (cachedReputation != null) {
        final successTrade = enrichedTrade.copyWith(reputation: UserReputation.success(cachedReputation));
        _enrichedController.add(successTrade);
        return;
      }

      // Fetch with retry strategy
      final requestId = ++_requestCounter;
      _activeRequestIds[trade.userId] = requestId;

      try {
        final reputation = await _retryStrategy.execute(() => _tradeService.fetchUserReputation(trade.userId));

        // Check if request is still relevant
        if (_activeRequestIds[trade.userId] == requestId) {
          _activeRequestIds.remove(trade.userId);
          _cache.put(trade.userId, reputation);

          final successTrade = enrichedTrade.copyWith(reputation: UserReputation.success(reputation));
          _enrichedController.add(successTrade);
        }
        // Else: late result, discard silently
      } catch (_) {
        // Check if request is still relevant
        if (_activeRequestIds[trade.userId] == requestId) {
          _activeRequestIds.remove(trade.userId);

          final errorTrade = enrichedTrade.copyWith(reputation: const UserReputation.error());
          _enrichedController.add(errorTrade);
        }
        // Else: late result, discard silently
      }
    });
  }

  @override
  Stream<EnrichedTrade> get enrichedTradeStream => _enrichedController.stream;

  @override
  Future<void> retryMetadataFetch(String userId) async {
    // Invalidate cache entry
    _cache.put(userId, ''); // Temporary, will be overwritten

    final requestId = ++_requestCounter;
    _activeRequestIds[userId] = requestId;

    try {
      final reputation = await _retryStrategy.execute(() => _tradeService.fetchUserReputation(userId));

      if (_activeRequestIds[userId] == requestId) {
        _activeRequestIds.remove(userId);
        _cache.put(userId, reputation);

        // Emit update for all trades with this userId
        // Note: This is a simplified approach. In production, you might
        // want to track which trades need updating.
      }
    } catch (_) {
      if (_activeRequestIds[userId] == requestId) {
        _activeRequestIds.remove(userId);
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _tradeSubscription?.cancel();
    await _enrichedController.close();
  }
}
