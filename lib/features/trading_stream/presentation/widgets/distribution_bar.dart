import 'package:flutter/material.dart';

import '../../domain/entities/trade_metrics.dart';

/// Asset distribution bar widget.
class DistributionBar extends StatelessWidget {
  final TradeMetrics metrics;

  const DistributionBar({
    super.key,
    required this.metrics,
  });

  // Symbol colors
  static const _symbolColors = {
    'BTC': Color(0xFFF7931A), // Orange
    'ETH': Color(0xFF627EEA), // Blue
    'SOL': Color(0xFF9945FF), // Purple
    'XRP': Color(0xFF23292F), // Dark grey
  };

  @override
  Widget build(BuildContext context) {
    if (metrics.assetDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 24,
              child: Row(
                children: _buildSegments(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: _buildLegend(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSegments() {
    final segments = <Widget>[];
    final sorted = metrics.assetDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      final percentage = entry.value;
      if (percentage > 0) {
        segments.add(
          Expanded(
            flex: (percentage * 1000).round(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _symbolColors[entry.key] ?? Colors.grey,
            ),
          ),
        );
      }
    }

    return segments;
  }

  List<Widget> _buildLegend() {
    final items = <Widget>[];
    final sorted = metrics.assetDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      if (entry.value > 0) {
        items.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                color: _symbolColors[entry.key] ?? Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }
    }

    return items;
  }
}

