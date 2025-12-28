import '../entities/enriched_trade.dart';

/// Domain repository interface for trade data.
abstract class ITradeRepository {
  /// Stream of enriched trades (trade + metadata).
  Stream<EnrichedTrade> get enrichedTradeStream;

  /// Manually retry metadata fetch for a specific userId.
  Future<void> retryMetadataFetch(String userId);

  /// Dispose resources.
  Future<void> dispose();
}

