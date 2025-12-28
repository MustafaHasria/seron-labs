import 'package:get_it/get_it.dart';

import '../../features/trading_stream/data/di.dart' as trading_stream;

/// Service locator instance.
final GetIt sl = GetIt.instance;

/// Initialize all application dependencies.
void initializeAppDependencies() {
  // Register trading stream feature
  trading_stream.registerTradingStreamDependencies(sl);
}

