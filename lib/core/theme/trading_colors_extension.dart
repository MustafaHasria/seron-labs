import 'package:flutter/material.dart';

/// Trading-specific semantic colors extension.
class TradingColors extends ThemeExtension<TradingColors> {
  final Color profit;
  final Color loss;
  final Color neutral;
  final Color stale;
  final Color loading;
  final Color error;

  const TradingColors({
    required this.profit,
    required this.loss,
    required this.neutral,
    required this.stale,
    required this.loading,
    required this.error,
  });

  @override
  ThemeExtension<TradingColors> copyWith({
    Color? profit,
    Color? loss,
    Color? neutral,
    Color? stale,
    Color? loading,
    Color? error,
  }) {
    return TradingColors(
      profit: profit ?? this.profit,
      loss: loss ?? this.loss,
      neutral: neutral ?? this.neutral,
      stale: stale ?? this.stale,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<TradingColors> lerp(
    ThemeExtension<TradingColors>? other,
    double t,
  ) {
    if (other is! TradingColors) {
      return this;
    }
    return TradingColors(
      profit: Color.lerp(profit, other.profit, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      stale: Color.lerp(stale, other.stale, t)!,
      loading: Color.lerp(loading, other.loading, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }

  /// Dark theme trading colors.
  static const dark = TradingColors(
    profit: Color(0xFF4CAF50), // Green
    loss: Color(0xFFF44336), // Red
    neutral: Color(0xFF9E9E9E), // Grey
    stale: Color(0xFF616161), // Dark grey
    loading: Color(0xFF2196F3), // Blue
    error: Color(0xFFFF5722), // Deep orange
  );
}

