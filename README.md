# Seron Labs - Trading Stream

A high-performance Flutter trading terminal demonstrating clean architecture, real-time data processing, and production-grade engineering practices.

## Architecture

Built with **Domain-Driven Design (DDD)** and strict **Clean Architecture** layering:

### Layer Structure
```
Domain (Pure Dart)
   ↓ depends on abstractions
Data (Repositories, Services, Models)
   ↓ provides implementations
Presentation (BLoC, UI)
```

- **Domain Layer**: Business logic, entities, repository interfaces (framework-agnostic)
- **Data Layer**: API clients, caching (LRU), retry logic, `freezed` models
- **Presentation Layer**: BLoC state management, Flutter widgets (no business logic)

### Key Patterns
- **Dependency Injection**: `get_it` for service location
- **State Management**: BLoC with one-way data flow (UI → Event → BLoC → State → UI)
- **Networking**: Centralized `Network_Client` using Dio
- **Time Abstraction**: Injectable `IClock` for testable time-dependent logic

## Data Flow

```
WebSocket Stream (50ms intervals)
    ↓
TradeFirehoseService
    ↓
TradeRepository ← MetadataRepository (with retry/cache)
    ↓
TradingStreamBloc (domain logic + metrics)
    ↓
UI (frozen/unfrozen states)
```

### Metadata Enrichment
- **Retry Strategy**: 4 attempts with exponential backoff (200ms, 400ms, 800ms)
- **Caching**: LRU cache (100 entries) to reduce redundant calls
- **Failure Handling**: Graceful degradation with stale indicators

### Real-Time Metrics
- **Total Volume**: Lossless accumulation across all trades
- **Rolling Average**: Last 50 trades using circular buffer (O(1) updates)
- **Asset Distribution**: Volume-based percentages per symbol

### Freeze Mode
- UI pauses rendering while domain continues processing
- On unfreeze: Smart reconciliation (animate small deltas, "Jump to Latest" for large gaps)
- Metrics remain accurate during freeze

## Testing

### Unit Tests
```bash
flutter test
```
- Rolling average logic (circular buffer)
- Retry & backoff strategy
- Metadata caching (LRU)

### Integration Tests
```bash
flutter test test/features/trading_stream/integration/
```
- Burst test: 100 events @ 10ms intervals
- Freeze mode correctness

### Golden Tests
```bash
flutter test test/features/trading_stream/presentation/widgets/trade_tile_golden_test.dart
```
- TradeTile states: loading, success, error, stale

### Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Setup

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test
```

## Project Structure

```
lib/
├── core/
│   ├── di/           # Dependency injection (get_it)
│   ├── theme/        # Material 3 theming
│   └── utils/        # Clock abstraction, PageState
├── features/
│   └── trading_stream/
│       ├── domain/   # Entities, repository interfaces
│       ├── data/     # Implementations, services, models
│       └── presentation/  # BLoC, pages, widgets
```

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architectural decisions
- [docs/PERFORMANCE.md](docs/PERFORMANCE.md) - Performance profiling
- [docs/TESTING.md](docs/TESTING.md) - Test coverage report
