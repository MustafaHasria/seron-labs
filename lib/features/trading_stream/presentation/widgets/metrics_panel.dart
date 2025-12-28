import 'package:flutter/material.dart';

import '../../domain/entities/trade_metrics.dart';

/// Metrics panel widget displaying total volume and rolling average.
class MetricsPanel extends StatelessWidget {
  final TradeMetrics metrics;

  const MetricsPanel({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetric(
              context,
              'Total Volume',
              _formatCurrency(metrics.totalVolume),
            ),
            _buildMetric(
              context,
              'Rolling Avg',
              _formatCurrency(metrics.rollingAverage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    if (value == 0) {
      return '\$0.00';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}

