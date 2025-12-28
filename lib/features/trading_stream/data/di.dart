import 'package:get_it/get_it.dart';

import '../../../core/utils/clock.dart';
import '../domain/repositories/i_trade_repository.dart';
import '../domain/services/i_metrics_engine.dart';
import '../presentation/bloc/trading_bloc.dart';
import 'repositories/trade_repository_impl.dart';
import 'services/lru_cache.dart';
import 'services/metrics_engine_impl.dart';
import 'services/mock_trade_service.dart';
import 'services/retry_strategy.dart';

/// Register trading stream feature dependencies.
void registerTradingStreamDependencies(GetIt sl) {
  // Core utilities
  sl.registerLazySingleton<IClock>(() => const SystemClock());

  // Services
  sl.registerLazySingleton<ITradeService>(
    () => MockTradeService(clock: sl()),
  );

  // Data layer
  sl.registerLazySingleton<LRUCache<String, String>>(
    () => LRUCache<String, String>(maxSize: 100),
  );
  sl.registerLazySingleton<RetryStrategy>(() => RetryStrategy());
  sl.registerLazySingleton<IMetricsEngine>(
    () => MetricsEngineImpl(clock: sl()),
  );

  // Repository
  sl.registerLazySingleton<ITradeRepository>(
    () => TradeRepositoryImpl(
      tradeService: sl(),
      cache: sl(),
      retryStrategy: sl(),
      clock: sl(),
    ),
  );

  // BLoC
  sl.registerFactory<TradingBloc>(
    () => TradingBloc(
      repository: sl(),
      metricsEngine: sl(),
    ),
  );
}

