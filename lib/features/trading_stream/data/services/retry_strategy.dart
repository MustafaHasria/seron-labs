/// Retry strategy with exponential backoff (no jitter).
class RetryStrategy {
  /// Maximum retries after initial attempt.
  static const maxRetries = 3;

  /// Backoff delays: 200ms, 400ms, 800ms.
  static const delays = [
    Duration(milliseconds: 200),
    Duration(milliseconds: 400),
    Duration(milliseconds: 800),
  ];

  /// Execute operation with retry logic.
  /// Returns result on success, throws exception if all attempts fail.
  Future<T> execute<T>(Future<T> Function() operation) async {
    Exception? lastException;

    // Attempt #1: immediate
    try {
      return await operation();
    } catch (e) {
      lastException = e is Exception ? e : Exception(e.toString());
      // Continue to retries
    }

    // Retries #1-3 with exponential backoff
    for (var i = 0; i < maxRetries; i++) {
      await Future<void>.delayed(delays[i]);
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        // Continue to next retry
      }
    }

    // All attempts failed - throw the last exception
    throw lastException ?? Exception('All retry attempts failed');
  }
}

