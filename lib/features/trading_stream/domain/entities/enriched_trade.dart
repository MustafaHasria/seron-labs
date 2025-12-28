import 'trade.dart';
import 'user_reputation.dart';

/// Trade enriched with metadata (reputation) state.
class EnrichedTrade {
  final Trade trade;
  final UserReputation reputation;

  const EnrichedTrade({
    required this.trade,
    required this.reputation,
  });

  EnrichedTrade copyWith({
    Trade? trade,
    UserReputation? reputation,
  }) {
    return EnrichedTrade(
      trade: trade ?? this.trade,
      reputation: reputation ?? this.reputation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnrichedTrade &&
          runtimeType == other.runtimeType &&
          trade == other.trade &&
          reputation == other.reputation;

  @override
  int get hashCode => trade.hashCode ^ reputation.hashCode;
}

