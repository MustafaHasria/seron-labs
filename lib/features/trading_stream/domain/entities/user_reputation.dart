import 'package:equatable/equatable.dart';

/// User reputation state (union type).
sealed class UserReputation extends Equatable {
  const UserReputation();

  /// Loading state - metadata fetch in progress.
  const factory UserReputation.loading() = LoadingReputation;

  /// Success state - reputation fetched successfully.
  const factory UserReputation.success(String reputation) = SuccessReputation;

  /// Error state - all retry attempts failed.
  const factory UserReputation.error() = ErrorReputation;

  /// Stale state - trade timestamp is older than threshold.
  const factory UserReputation.stale() = StaleReputation;

  @override
  List<Object?> get props => [];
}

/// Loading state implementation.
final class LoadingReputation extends UserReputation {
  const LoadingReputation();

  @override
  List<Object?> get props => [];
}

/// Success state implementation.
final class SuccessReputation extends UserReputation {
  final String reputation;

  const SuccessReputation(this.reputation);

  @override
  List<Object?> get props => [reputation];
}

/// Error state implementation.
final class ErrorReputation extends UserReputation {
  const ErrorReputation();

  @override
  List<Object?> get props => [];
}

/// Stale state implementation.
final class StaleReputation extends UserReputation {
  const StaleReputation();

  @override
  List<Object?> get props => [];
}

