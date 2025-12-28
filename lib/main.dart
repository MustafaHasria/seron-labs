import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_dependencies.dart';
import 'core/theme/app_theme.dart';
import 'features/trading_stream/presentation/bloc/trading_bloc.dart';
import 'features/trading_stream/presentation/pages/trading_dashboard_page.dart';

void main() {
  // Initialize dependency injection
  initializeAppDependencies();

  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resilient Exchange Engine',
      theme: AppTheme.darkTheme,
      home: BlocProvider(
        create: (context) => sl<TradingBloc>(),
        child: const TradingDashboardPage(),
      ),
    );
  }
}
