import 'package:flutter/material.dart';

import 'trading_colors_extension.dart';

/// Application theme configuration.
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        TradingColors.dark,
      ],
    );
  }
}

