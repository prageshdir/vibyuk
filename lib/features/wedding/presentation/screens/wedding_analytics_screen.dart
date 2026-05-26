import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_analytics/wedding_analytics_cubit.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/budget_pie_chart.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/wedding_progress_ring.dart';

class WeddingAnalyticsScreen extends StatefulWidget {
  final String weddingId;
  const WeddingAnalyticsScreen({super.key, required this.weddingId});

  @override
  State<WeddingAnalyticsScreen> createState() => _WeddingAnalyticsScreenState();
}

class _WeddingAnalyticsScreenState extends State<WeddingAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WeddingAnalyticsCubit>().load(widget.weddingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wedding Analytics')),
      body: BlocBuilder<WeddingAnalyticsCubit, WeddingAnalyticsState>(
        builder: (context, state) => switch (state) {
          WeddingAnalyticsInitial() ||
          WeddingAnalyticsLoading() =>
            const Center(child: CircularProgressIndicator()),
          WeddingAnalyticsError(:final failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(failure.message),
                  ElevatedButton(
                    onPressed: () => context.read<WeddingAnalyticsCubit>().load(widget.weddingId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          WeddingAnalyticsLoaded(:final analytics) => RefreshIndicator(
              onRefresh: () async => context.read<WeddingAnalyticsCubit>().load(widget.weddingId),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Overview rings row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      WeddingProgressRing(
                        progress: analytics.budgetUsedPercentage / 100,
                        label: '${analytics.budgetUsedPercentage.toStringAsFixed(0)}%',
                        sublabel: 'Budget\nUsed',
                        size: 110,
                        color: analytics.budgetUsedPercentage > 90
                            ? Colors.red
                            : analytics.budgetUsedPercentage > 70
                                ? Colors.orange
                                : Colors.green,
                      ),
                      WeddingProgressRing(
                        progress: analytics.timelineCompletionRate,
                        label: '${(analytics.timelineCompletionRate * 100).toStringAsFixed(0)}%',
                        sublabel: 'Timeline\nDone',
                        size: 110,
                        color: Colors.blue,
                      ),
                      WeddingProgressRing(
                        progress: analytics.guestConfirmationRate,
                        label: '${(analytics.guestConfirmationRate * 100).toStringAsFixed(0)}%',
                        sublabel: 'Guests\nRSVP',
                        size: 110,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Key stats card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Key Metrics',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Divider(),
                          _MetricRow(label: 'Days Until Wedding', value: '${analytics.daysUntilWedding}'),
                          _MetricRow(
                            label: 'Budget Remaining',
                            value: '\$${analytics.budgetRemaining.toStringAsFixed(0)}',
                            highlight: analytics.budgetRemaining < 0,
                          ),
                          _MetricRow(label: 'Vendors Booked', value: '${analytics.vendorsBooked}'),
                          _MetricRow(label: 'Vendors Pending', value: '${analytics.vendorsPending}'),
                          _MetricRow(label: 'Top Expense', value: analytics.topExpenseCategory),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Budget breakdown pie chart
                  Text(
                    'Budget by Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BudgetPieChart(
                        budgetByCategory: analytics.budgetByCategory,
                        totalBudget: analytics.totalBudget,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
        },
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _MetricRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: highlight ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
