import 'package:flutter/material.dart';

import '../../../../core/theme/trading_colors_extension.dart';
import 'sparkline_painter.dart';

/// Trade tile state.
enum TradeTileState { loading, success, error, stale }

/// Interface for trade tile data (polymorphic design).
abstract class ITradeTileData {
  String get primaryLabel; // e.g., "BTC"
  String get secondaryLabel; // e.g., "$45,000"
  String get tertiaryLabel; // e.g., "Rep: 85"
  TradeTileState get state;
  List<double> get sparklineData;
  VoidCallback? get onRetry;
}

/// Reusable trade tile widget (domain-agnostic).
class TradeTile extends StatelessWidget {
  final ITradeTileData data;

  const TradeTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TradingColors>()!;
    final isStale = data.state == TradeTileState.stale;

    return Opacity(
      opacity: isStale ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Symbol
              Expanded(
                flex: 2,
                child: Text(
                  data.primaryLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              // Price
              Expanded(flex: 3, child: Text(data.secondaryLabel, style: Theme.of(context).textTheme.bodyLarge)),
              // Sparkline
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: CustomPaint(
                    painter: SparklinePainter(prices: data.sparklineData, color: _getStateColor(colors, data.state)),
                  ),
                ),
              ),
              // Reputation/Status
              Expanded(flex: 2, child: _buildReputationWidget(context, colors)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReputationWidget(BuildContext context, TradingColors colors) {
    switch (data.state) {
      case TradeTileState.loading:
        return UnconstrainedBox(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(colors.loading)),
          ),
        );
      case TradeTileState.success:
        return Center(
          child: Text(
            data.tertiaryLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.neutral),
          ),
        );
      case TradeTileState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 16, color: colors.error),
            if (data.onRetry != null)
              TextButton(
                onPressed: data.onRetry,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Retry', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.error)),
              ),
          ],
        );
      case TradeTileState.stale:
        return Icon(Icons.access_time, size: 16, color: colors.stale);
    }
  }

  Color _getStateColor(TradingColors colors, TradeTileState state) {
    switch (state) {
      case TradeTileState.loading:
        return colors.loading;
      case TradeTileState.success:
        return colors.neutral;
      case TradeTileState.error:
        return colors.error;
      case TradeTileState.stale:
        return colors.stale;
    }
  }
}
