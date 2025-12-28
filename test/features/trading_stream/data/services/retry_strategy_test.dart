import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/trading_stream/data/services/retry_strategy.dart';

void main() {
  group('RetryStrategy', () {
    late RetryStrategy strategy;

    setUp(() {
      strategy = RetryStrategy();
    });

    test('success on first attempt - no retries needed', () async {
      var attemptCount = 0;
      final result = await strategy.execute(() async {
        attemptCount++;
        return 'success';
      });

      expect(result, 'success');
      expect(attemptCount, 1);
    });

    test('failure then success on retry #1 (after 200ms)', () async {
      var attemptCount = 0;
      final stopwatch = Stopwatch()..start();

      final result = await strategy.execute(() async {
        attemptCount++;
        if (attemptCount == 1) {
          throw Exception('fail');
        }
        return 'success';
      });

      stopwatch.stop();

      expect(result, 'success');
      expect(attemptCount, 2);
      // Should have waited ~200ms
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(200));
      expect(stopwatch.elapsedMilliseconds, lessThan(250)); // Allow small margin
    });

    test('failure then success on retry #2 (after 400ms)', () async {
      var attemptCount = 0;
      final stopwatch = Stopwatch()..start();

      final result = await strategy.execute(() async {
        attemptCount++;
        if (attemptCount <= 2) {
          throw Exception('fail');
        }
        return 'success';
      });

      stopwatch.stop();

      expect(result, 'success');
      expect(attemptCount, 3);
      // Should have waited ~200ms + 400ms = 600ms
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(600));
      expect(stopwatch.elapsedMilliseconds, lessThan(650));
    });

    test('failure then success on retry #3 (after 800ms)', () async {
      var attemptCount = 0;
      final stopwatch = Stopwatch()..start();

      final result = await strategy.execute(() async {
        attemptCount++;
        if (attemptCount <= 3) {
          throw Exception('fail');
        }
        return 'success';
      });

      stopwatch.stop();

      expect(result, 'success');
      expect(attemptCount, 4);
      // Should have waited ~200ms + 400ms + 800ms = 1400ms
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1400));
      expect(stopwatch.elapsedMilliseconds, lessThan(1450));
    });

    test('all 4 attempts fail - return error', () async {
      var attemptCount = 0;
      final stopwatch = Stopwatch()..start();

      expect(
        () => strategy.execute(() async {
          attemptCount++;
          throw Exception('fail');
        }),
        throwsA(isA<Exception>()),
      );

      stopwatch.stop();

      expect(attemptCount, 4);
      // Should have waited ~200ms + 400ms + 800ms = 1400ms
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1400));
      expect(stopwatch.elapsedMilliseconds, lessThan(1450));
    });

    test('verify exact delay timing', () async {
      var attemptCount = 0;
      final delays = <Duration>[];
      var lastTime = DateTime.now();

      try {
        await strategy.execute(() async {
          final now = DateTime.now();
          if (attemptCount > 0) {
            delays.add(now.difference(lastTime));
          }
          lastTime = now;
          attemptCount++;
          if (attemptCount <= 3) {
            throw Exception('fail');
          }
          return 'success';
        });
      } catch (_) {
        // Expected for this test
      }

      // Verify delays are approximately correct
      if (delays.length >= 1) {
        expect(delays[0].inMilliseconds, greaterThanOrEqualTo(200));
        expect(delays[0].inMilliseconds, lessThan(250));
      }
      if (delays.length >= 2) {
        expect(delays[1].inMilliseconds, greaterThanOrEqualTo(400));
        expect(delays[1].inMilliseconds, lessThan(450));
      }
      if (delays.length >= 3) {
        expect(delays[2].inMilliseconds, greaterThanOrEqualTo(800));
        expect(delays[2].inMilliseconds, lessThan(850));
      }
    });
  });
}

