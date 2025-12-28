/// Clock abstraction for deterministic testing and stale state detection.
abstract class IClock {
  /// Returns the current date and time.
  DateTime now();
}

/// System clock implementation using DateTime.now().
class SystemClock implements IClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Fixed clock implementation for testing.
class FixedClock implements IClock {
  final DateTime _fixedTime;

  FixedClock(this._fixedTime);

  @override
  DateTime now() => _fixedTime;
}

