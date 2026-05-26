import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/features/events/domain/entities/event_analytics_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_dashboard/event_dashboard_bloc.dart';
import 'package:vibyuk/features/events/presentation/widgets/analytics_chart_widget.dart';
import 'package:vibyuk/features/events/presentation/widgets/capacity_bar_widget.dart';

class EventDashboardScreen extends StatefulWidget {
  final String eventId;
  const EventDashboardScreen({super.key, required this.eventId});

  @override
  State<EventDashboardScreen> createState() => _EventDashboardScreenState();
}

class _EventDashboardScreenState extends State<EventDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<EventDashboardBloc>()
          .add(EventDashboardLoadRequested(eventId: widget.eventId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDashboardBloc, EventDashboardState>(
      builder: (context, state) {
        if (state is EventDashboardLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is EventDashboardError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Dashboard')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.failure.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<EventDashboardBloc>().add(
                          EventDashboardLoadRequested(eventId: widget.eventId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! EventDashboardLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _DashboardView(
          event: state.event,
          analytics: state.analytics,
          isRefreshing: state.isRefreshing,
          onRefresh: () => context
              .read<EventDashboardBloc>()
              .add(const EventDashboardRefreshRequested()),
        );
      },
    );
  }
}

class _DashboardView extends StatelessWidget {
  final EventEntity event;
  final EventAnalyticsEntity analytics;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const _DashboardView({
    required this.event,
    required this.analytics,
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              title: Text(event.title),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StatusChip(status: event.status),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => context.push(
                    '${RouteNames.ticketScanner}?eventId=${event.id}',
                  ),
                  tooltip: 'Scan Tickets',
                ),
              ],
            ),
            if (isRefreshing)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats overview
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.8,
                      children: [
                        _StatCard(
                          title: 'Sold',
                          value:
                              '${analytics.soldTickets} / ${analytics.totalCapacity}',
                          icon: Icons.confirmation_number_outlined,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Revenue',
                          value: currencyFormat.format(analytics.totalRevenue),
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                        _StatCard(
                          title: 'Checked In',
                          value:
                              '${analytics.checkedIn} / ${analytics.soldTickets}',
                          icon: Icons.how_to_reg_outlined,
                          color: Colors.purple,
                        ),
                        _StatCard(
                          title: 'Refunds',
                          value: '${analytics.pendingRefunds} pending',
                          icon: Icons.money_off_outlined,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CapacityBarWidget(
                      sold: analytics.soldTickets,
                      total: analytics.totalCapacity,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: AnalyticsChartWidget(
                          analytics: analytics,
                          title: 'Sales Analytics',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'By Ticket Type',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...analytics.salesByType.map((t) => _TicketTypeRow(
                          name: t.name,
                          tier: t.tier.name.toUpperCase(),
                          quantity: t.quantity,
                          revenue: currencyFormat.format(t.revenue),
                        )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketTypeRow extends StatelessWidget {
  final String name;
  final String tier;
  final int quantity;
  final String revenue;

  const _TicketTypeRow({
    required this.name,
    required this.tier,
    required this.quantity,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(tier,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        )),
              ],
            ),
          ),
          Text(
            '$quantity sold',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            revenue,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      EventStatus.published => (Colors.green, 'Live'),
      EventStatus.draft => (Colors.orange, 'Draft'),
      EventStatus.cancelled => (Colors.red, 'Cancelled'),
      EventStatus.ended => (Colors.grey, 'Ended'),
      EventStatus.soldOut => (Colors.purple, 'Sold Out'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
