import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/presentation/blocs/analytics/analytics_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/bookings_bar_chart.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';
import 'package:vibyuk/features/business/presentation/widgets/kpi_card.dart';
import 'package:vibyuk/features/business/presentation/widgets/spend_line_chart.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends State<AnalyticsDashboardScreen> {
  static const _periods = [
    ('7 days', '7d'),
    ('30 days', '30d'),
    ('90 days', '90d'),
    ('Year', '1y'),
  ];

  @override
  void initState() {
    super.initState();
    context
        .read<AnalyticsBloc>()
        .add(const LoadAnalyticsDashboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) => switch (state) {
          AnalyticsLoadingState() =>
            const Center(child: AppLoader()),
          AnalyticsLoadedState(:final dashboard, :final selectedPeriod) =>
            RefreshIndicator(
              onRefresh: () async => context
                  .read<AnalyticsBloc>()
                  .add(LoadAnalyticsDashboardEvent(
                      period: selectedPeriod)),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PeriodSelector(
                      periods: _periods,
                      selected: selectedPeriod,
                      onChanged: (p) => context
                          .read<AnalyticsBloc>()
                          .add(ChangePeriodEvent(period: p)),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        KpiCard(
                          title: 'Total spend',
                          value: dashboard.totalSpendDisplay,
                          icon: Icons.payments_rounded,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primaryContainer,
                        ),
                        KpiCard(
                          title: 'Active campaigns',
                          value: '${dashboard.activeCampaigns}',
                          icon: Icons.campaign_rounded,
                          iconColor: AppColors.secondary,
                          iconBgColor: AppColors.secondaryContainer,
                        ),
                        KpiCard(
                          title: 'Creators booked',
                          value: '${dashboard.totalCreators}',
                          icon: Icons.people_rounded,
                          iconColor: AppColors.tertiary,
                          iconBgColor: AppColors.tertiaryContainer,
                        ),
                        KpiCard(
                          title: 'Avg. rating',
                          value: dashboard.avgRatingDisplay,
                          icon: Icons.star_rounded,
                          iconColor: AppColors.warning,
                          iconBgColor: AppColors.warningContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (dashboard.spendOverTime.isNotEmpty) ...[
                      _SectionHeader(title: 'Spend over time'),
                      const SizedBox(height: 12),
                      SpendLineChart(points: dashboard.spendOverTime),
                      const SizedBox(height: 24),
                    ],
                    if (dashboard.bookingsByStatus.isNotEmpty) ...[
                      _SectionHeader(title: 'Bookings by status'),
                      const SizedBox(height: 12),
                      BookingsBarChart(
                          bookingsByStatus:
                              dashboard.bookingsByStatus),
                      const SizedBox(height: 24),
                    ],
                    if (dashboard.topCategories.isNotEmpty) ...[
                      _SectionHeader(title: 'Top categories'),
                      const SizedBox(height: 12),
                      ...dashboard.topCategories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CategoryBar(
                            name: cat.category,
                            count: cat.count,
                            percentage: cat.percentage,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          AnalyticsErrorState(:final failure) =>
            BusinessEmptyState(
              title: 'Failed to load analytics',
              description: failure.message,
              icon: Icons.bar_chart_rounded,
              actionLabel: 'Retry',
              onAction: () => context
                  .read<AnalyticsBloc>()
                  .add(const LoadAnalyticsDashboardEvent()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final List<(String, String)> periods;
  final String selected;
  final ValueChanged<String> onChanged;

  const _PeriodSelector({
    required this.periods,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map(((String label, String value) p) {
          final isSelected = p.$2 == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p.$1),
              selected: isSelected,
              onSelected: (_) => onChanged(p.$2),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String name;
  final int count;
  final double percentage;

  const _CategoryBar({
    required this.name,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
            Text(
              '$count · ${percentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: AppColors.outlineVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary),
          ),
        ),
      ],
    );
  }
}
