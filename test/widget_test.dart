// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seron_labs/core/di/app_dependencies.dart';
import 'package:seron_labs/features/trading_stream/data/services/mock_trade_service.dart';
import 'package:seron_labs/features/trading_stream/domain/repositories/i_trade_repository.dart';
import 'package:seron_labs/main.dart';

void main() {
  setUp(() {
    // Initialize dependency injection for tests
    initializeAppDependencies();
  });

  tearDown(() async {
    // Clean up in reverse order of dependency
    try {
      // 1. Dispose repository (cancels subscription to service)
      if (sl.isRegistered<ITradeRepository>()) {
        try {
          final repository = sl<ITradeRepository>();
          await repository.dispose();
        } catch (_) {
          // Already disposed or not instantiated
        }
      }

      // 2. Dispose service (stops timer)
      if (sl.isRegistered<ITradeService>()) {
        try {
          final service = sl<ITradeService>();
          if (service is MockTradeService) {
            await service.dispose();
          }
        } catch (_) {
          // Already disposed or not instantiated
        }
      }

      // 3. Reset DI container
      await sl.reset();
    } catch (e) {
      // Ensure tearDown completes even if cleanup fails
      debugPrint('Teardown error: $e');
    }
  });

  testWidgets('Trading app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TradingApp());
    
    // Verify that the trading dashboard is displayed.
    expect(find.text('Trading Terminal'), findsOneWidget);
    
    // Wait a bit to see some data flow
    await tester.pump(const Duration(milliseconds: 100));

    // Clean up: manually dispose resources BEFORE disposing widget
    // This is necessary because the repository is a singleton and won't
    // be automatically disposed when the BLoC closes.
    if (sl.isRegistered<ITradeRepository>()) {
      final repository = sl<ITradeRepository>();
      await repository.dispose();
    }
    
    if (sl.isRegistered<ITradeService>()) {
      final service = sl<ITradeService>();
      if (service is MockTradeService) {
        await service.dispose();
      }
    }

    // Now dispose the widget tree
    await tester.pumpWidget(Container());
    
    // Pump to process any remaining microtasks
    await tester.pump();
  });
}
