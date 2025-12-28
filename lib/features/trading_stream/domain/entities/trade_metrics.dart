import 'package:equatable/equatable.dart';

/// Real-time trading metrics.
class TradeMetrics extends Equatable {
  /// Persistent total volume (lossless sum of all prices).
  final double totalVolume;

  /// Rolling average price (last 50 trades).
  final double rollingAverage;

  /// Asset distribution (symbol -> percentage based on volume).
  final Map<String, double> assetDistribution;

  const TradeMetrics({
    required this.totalVolume,
    required this.rollingAverage,
    required this.assetDistribution,
  });

  TradeMetrics copyWith({
    double? totalVolume,
    double? rollingAverage,
    Map<String, double>? assetDistribution,
  }) {
    return TradeMetrics(
      totalVolume: totalVolume ?? this.totalVolume,
      rollingAverage: rollingAverage ?? this.rollingAverage,
      assetDistribution: assetDistribution ?? this.assetDistribution,
    );
  }

  @override
  List<Object?> get props => [totalVolume, rollingAverage, assetDistribution];
}

