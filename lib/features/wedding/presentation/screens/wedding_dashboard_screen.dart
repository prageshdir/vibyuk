import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_dashboard/wedding_dashboard_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/wedding_progress_ring.dart';

class WeddingDashboardScreen extends StatefulWidget {
  final String? weddingId;
  const WeddingDashboardScreen({super.key, this.weddingId});

  @override
  State<WeddingDashboardScreen> createState() => _WeddingDashboardScreenState();
}

class _WeddingDashboardScreenState extends State<WeddingDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final id = widget.weddingId ?? 'default';
    context
        .read<WeddingDashboardBloc>()
        .add(WeddingDashboardLoadRequested(weddingId: id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WeddingDashboardBloc, WeddingDashboardState>(
        builder: (context, state) => switch (state) {
          WeddingDashboardInitial() || WeddingDashboardLoading() =>
            const Center(child: CircularProgressIndicator()),
          WeddingDashboardError(:final failure) => _ErrorView(
              message: failure.message,
              onRetry: () => context.read<WeddingDashboardBloc>().add(
                    const WeddingDashboardRefreshRequested(),
                  ),
            ),
          WeddingDashboardLoaded() => _LoadedView(state: state),
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final WeddingDashboardLoaded state;
  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wedding = state.wedding;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WeddingDashboardBloc>().add(
              const WeddingDashboardRefreshRequested(),
            );
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(wedding.coupleNames),
            subtitle: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(wedding.weddingDate),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                onPressed: () => context.push(
                  '${RouteNames.weddingAnalytics}?weddingId=${wedding.id}',
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Countdown + progress
                _CountdownCard(wedding: wedding, completionRate: state.completionRate),
                const SizedBox(height: 16),

                // Stats row
                _StatsRow(analytics: state.analytics),
                const SizedBox(height: 16),

                // Budget overview
                _BudgetOverview(analytics: state.analytics, totalBudget: wedding.totalBudget),
                const SizedBox(height: 16),

                // Quick actions
                _QuickActions(weddingId: wedding.id),
                const SizedBox(height: 16),

                // Upcoming tasks
                if (state.upcomingTasks.isNotEmpty) ...[
                  Text('Upcoming Tasks', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...state.upcomingTasks.map((task) => ListTile(
                        leading: Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.isCompleted ? Colors.green : null,
                        ),
                        title: Text(task.title),
                        subtitle: Text(
                          DateFormat('MMM d').format(task.dueDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: task.isOverdue ? theme.colorScheme.error : null,
                          ),
                        ),
                        dense: true,
                      )),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push(
                      '${RouteNames.weddingTimeline}?weddingId=${wedding.id}',
                    ),
                    child: const Text('View all tasks'),
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final dynamic wedding;
  final double completionRate;
  const _CountdownCard({required this.wedding, required this.completionRate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            WeddingProgressRing(
              progress: completionRate,
              label: '${(completionRate * 100).toStringAsFixed(0)}%',
              sublabel: 'Done',
              size: 90,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${wedding.daysUntilWedding}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text('days to go', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    wedding.venueName ?? 'Venue TBD',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
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

class _StatsRow extends StatelessWidget {
  final dynamic analytics;
  const _StatsRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'Vendors',
            value: '${analytics.vendorsBooked}',
            icon: Icons.people_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: 'Pending',
            value: '${analytics.vendorsPending}',
            icon: Icons.pending_outlined,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: 'RSVP',
            value: '${(analytics.guestConfirmationRate * 100).toStringAsFixed(0)}%',
            icon: Icons.how_to_reg_outlined,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BudgetOverview extends StatelessWidget {
  final dynamic analytics;
  final double totalBudget;
  const _BudgetOverview({required this.analytics, required this.totalBudget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = analytics.budgetUsedPercentage / 100;
    final color = pct < 0.5 ? Colors.green : pct < 0.8 ? Colors.orange : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => context.push(
                    '${RouteNames.weddingBudgetTracker}?weddingId=${analytics.weddingId}',
                  ),
                  child: const Text('Details'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${analytics.budgetUsed.toStringAsFixed(0)} used',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '₹${analytics.budgetRemaining.toStringAsFixed(0)} left',
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String weddingId;
  const _QuickActions({required this.weddingId});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.store_outlined, 'Vendors', RouteNames.weddingMarketplace),
      (Icons.location_city_outlined, 'Venues', RouteNames.weddingVenueListing),
      (Icons.inventory_2_outlined, 'Packages', RouteNames.weddingPackageBuilder),
      (Icons.timeline_outlined, 'Timeline', '${RouteNames.weddingTimeline}?weddingId=$weddingId'),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) {
        final (icon, label, route) = a;
        return _QuickActionButton(icon: icon, label: label, route: route);
      }).toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _QuickActionButton({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}
