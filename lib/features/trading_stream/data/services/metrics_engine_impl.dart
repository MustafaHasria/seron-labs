import 'dart:async';

import '../../../../core/utils/clock.dart';
import '../../domain/entities/trade.dart';
import '../../domain/entities/trade_metrics.dart';
import '../../domain/services/i_metrics_engine.dart';

/// Metrics engine implementation with efficient rolling average calculation.
class MetricsEngineImpl implements IMetricsEngine {
  final IClock _clock;
  final StreamController<TradeMetrics> _metricsController;

  // Total volume accumulator (lossless)
  double _totalVolume = 0.0;

  // Rolling average: circular buffer for last 50 trades
  final List<double> _priceBuffer = [];
  static const int _bufferSize = 50;
  double _runningSum = 0.0;

  // Asset distribution: volume per symbol
  final Map<String, double> _symbolVolumes = {};

  MetricsEngineImpl({required IClock clock})
    : _clock = clock,
      _metricsController = StreamController<TradeMetrics>.broadcast() {
    // Emit initial metrics
    _emitMetrics();
  }

  @override
  void processTrade(Trade trade) {
    // Update total volume (lossless)
    _totalVolume += trade.price;

    // Update rolling average buffer
    if (_priceBuffer.length >= _bufferSize) {
      // Remove oldest price from running sum
      _runningSum -= _priceBuffer.removeAt(0);
    }
    _priceBuffer.add(trade.price);
    _runningSum += trade.price;

    // Update asset distribution
    _symbolVolumes[trade.symbol] = (_symbolVolumes[trade.symbol] ?? 0.0) + trade.price;

    // Emit updated metrics
    _emitMetrics();
  }

  void _emitMetrics() {
    // Calculate rolling average
    final rollingAverage = _priceBuffer.isEmpty ? 0.0 : _runningSum / _priceBuffer.length;

    // Calculate asset distribution percentages
    final distribution = <String, double>{};
    if (_totalVolume > 0) {
      _symbolVolumes.forEach((symbol, volume) {
        distribution[symbol] = volume / _totalVolume;
      });
    }

    final metrics = TradeMetrics(
      totalVolume: _totalVolume,
      rollingAverage: rollingAverage,
      assetDistribution: distribution,
    );

    _metricsController.add(metrics);
  }

  @override
  Stream<TradeMetrics> get metricsStream => _metricsController.stream;

  @override
  TradeMetrics get currentMetrics {
    final rollingAverage = _priceBuffer.isEmpty ? 0.0 : _runningSum / _priceBuffer.length;

    final distribution = <String, double>{};
    if (_totalVolume > 0) {
      _symbolVolumes.forEach((symbol, volume) {
        distribution[symbol] = volume / _totalVolume;
      });
    }

    return TradeMetrics(totalVolume: _totalVolume, rollingAverage: rollingAverage, assetDistribution: distribution);
  }

  void dispose() {
    _metricsController.close();
  }
}
