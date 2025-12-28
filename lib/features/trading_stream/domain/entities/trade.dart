/// Pure trade data entity (domain layer).
class Trade {
  final String tradeId;
  final String userId;
  final String symbol;
  final double price;
  final DateTime timestamp;

  const Trade({
    required this.tradeId,
    required this.userId,
    required this.symbol,
    required this.price,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trade &&
          runtimeType == other.runtimeType &&
          tradeId == other.tradeId &&
          userId == other.userId &&
          symbol == other.symbol &&
          price == other.price &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      tradeId.hashCode ^
      userId.hashCode ^
      symbol.hashCode ^
      price.hashCode ^
      timestamp.hashCode;
}

