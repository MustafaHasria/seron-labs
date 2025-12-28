import '../entities/trade.dart';
import '../entities/trade_metrics.dart';

/// Domain service interface for metrics calculation.
abstract class IMetricsEngine {
  /// Process a new trade and update metrics.
  void processTrade(Trade trade);

  /// Get current metrics as a stream.
  Stream<TradeMetrics> get metricsStream;

  /// Get current metrics snapshot.
  TradeMetrics get currentMetrics;
}

