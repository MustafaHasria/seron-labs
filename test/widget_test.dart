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
  });

  testWidgets('Trading app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TradingApp());
    
    // Pump a few frames to ensure initialization completes
    await tester.pump();
    await tester.pump();

    // Verify that the trading dashboard is displayed.
    expect(find.text('Trading Terminal'), findsOneWidget);

    // Dispose the widget tree explicitly before test ends
    await tester.pumpWidget(Container());
    
    // Give time for async dispose operations to complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
