import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/page_state.dart';
import '../../domain/entities/user_reputation.dart';
import '../bloc/trading_bloc.dart';
import '../bloc/trading_event.dart';
import '../bloc/trading_state.dart';
import '../widgets/distribution_bar.dart';
import '../widgets/freeze_banner.dart';
import '../widgets/metrics_panel.dart';
import '../widgets/trade_tile.dart';
import '../widgets/trade_tile_adapter.dart';

/// Trading dashboard page.
class TradingDashboardPage extends StatefulWidget {
  const TradingDashboardPage({super.key});

  @override
  State<TradingDashboardPage> createState() => _TradingDashboardPageState();
}

class _TradingDashboardPageState extends State<TradingDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Start trading stream when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingBloc>().add(const TradingStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Terminal'),
        actions: [
          BlocBuilder<TradingBloc, TradingState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.isFrozen ? Icons.play_arrow : Icons.pause),
                onPressed: () {
                  context.read<TradingBloc>().add(const TradingToggleFreeze());
                },
                tooltip: state.isFrozen ? 'Unfreeze' : 'Freeze',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TradingBloc, TradingState>(
        builder: (context, state) {
          if (state.pageState == PageState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Distribution Bar
              DistributionBar(metrics: state.metrics),

              // Metrics Panel
              MetricsPanel(metrics: state.metrics),

              // Freeze Banner (if needed)
              if (state.showJumpBanner)
                FreezeBanner(
                  onJumpToLatest: () {
                    context.read<TradingBloc>().add(const TradingJumpToLatest());
                  },
                ),

              // Trade List
              Expanded(
                child: state.visibleTrades.isEmpty
                    ? const Center(child: Text('No trades yet'))
                    : ListView.builder(
                        itemCount: state.visibleTrades.length,
                        reverse: false,
                        itemBuilder: (context, index) {
                          final trade = state.visibleTrades[index];
                          final sparklineData = state.sparklineData[trade.trade.symbol] ?? [];
                          return TradeTile(
                            data: TradeTileAdapter(
                              enrichedTrade: trade,
                              sparklineData: sparklineData,
                              onRetry: trade.reputation is ErrorReputation
                                  ? () {
                                      context.read<TradingBloc>().add(TradingRetryMetadata(trade.trade.userId));
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
