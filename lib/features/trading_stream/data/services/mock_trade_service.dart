import 'dart:async';
import 'dart:math';

import '../../../../core/utils/clock.dart';

/// Trade raw data model (infrastructure layer).
class TradeRawData {
  final String tradeId;
  final String userId;
  final String symbol;
  final double price;
  final DateTime timestamp;

  TradeRawData({
    required this.tradeId,
    required this.userId,
    required this.symbol,
    required this.price,
    required this.timestamp,
  });
}

/// Trade service interface (infrastructure contract).
abstract class ITradeService {
  Stream<TradeRawData> get tradeStream;
  Future<String> fetchUserReputation(String userId);
}

/// Mock trade service implementation.
class MockTradeService implements ITradeService {
  final IClock clock;
  final Random _rng;
  final Duration firehoseInterval;
  final Duration metadataLatency;
  final double metadataFailureRate;
  final List<String> symbols;
  final List<String> userIds;
  late final StreamController<TradeRawData> _controller;
  Timer? _timer;
  int _tradeCounter = 0;

  MockTradeService({
    required this.clock,
    int? seed,
    this.firehoseInterval = const Duration(milliseconds: 50),
    this.metadataLatency = const Duration(seconds: 2),
    this.metadataFailureRate = 0.35,
    this.symbols = const ['BTC', 'ETH', 'SOL', 'XRP'],
    this.userIds = const ['u1', 'u2', 'u3', 'u4', 'u5', 'u6'],
  }) : _rng = Random(seed) {
    _controller = StreamController<TradeRawData>.broadcast(onListen: _start, onCancel: _stop);
  }

  @override
  Stream<TradeRawData> get tradeStream => _controller.stream;

  void _start() {
    _timer ??= Timer.periodic(firehoseInterval, (_) {
      _tradeCounter++;
      final symbol = symbols[_rng.nextInt(symbols.length)];
      final userId = userIds[_rng.nextInt(userIds.length)];
      // Produce a price that moves somewhat realistically around a
      // baseline per symbol.
      final baseline = _baselineFor(symbol);
      final jitter = (_rng.nextDouble() - 0.5) * baseline * 0.01; // +/-0.5% jitter
      final price = (baseline + jitter).clamp(0.01, double.infinity);
      final trade = TradeRawData(
        tradeId: 't$_tradeCounter',
        userId: userId,
        symbol: symbol,
        price: price.toDouble(),
        timestamp: clock.now(),
      );
      _controller.add(trade);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  double _baselineFor(String symbol) {
    switch (symbol) {
      case 'BTC':
        return 45000.0;
      case 'ETH':
        return 2500.0;
      case 'SOL':
        return 90.0;
      case 'XRP':
        return 0.55;
      default:
        return 100.0;
    }
  }

  @override
  Future<String> fetchUserReputation(String userId) async {
    await Future<void>.delayed(metadataLatency);
    // Random failure
    final willFail = _rng.nextDouble() < metadataFailureRate;
    if (willFail) {
      throw Exception('Metadata fetch failed for userId=$userId');
    }
    // Return a deterministic-ish value for demo
    // (You can choose to parse this in your domain layer however you want.)
    final reputationScore = 1 + _rng.nextInt(100);
    return 'Rep:$reputationScore';
  }

  Future<void> dispose() async {
    _stop();
    await _controller.close();
  }
}
