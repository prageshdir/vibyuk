import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_platform_analytics.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_analytics/admin_analytics_bloc.dart';
import 'package:vibyuk/features/admin/presentation/widgets/charts/admin_bar_chart.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_stat_card.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminAnalyticsBloc>().add(AdminAnalyticsFetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AdminAnalyticsBloc, AdminAnalyticsState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: const Text(
                  'Platform Analytics',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: _PeriodSelector(
                    selected: state.selectedPeriod,
                    onChanged: (p) => context
                        .read<AdminAnalyticsBloc>()
                        .add(AdminAnalyticsPeriodChanged(p)),
                  ),
                ),
              ),
              if (state.status == AdminAnalyticsLoadStatus.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.analytics == null)
                const SliverFillRemaining(
                  child: Center(child: Text('No data available')),
                )
              else
                _AnalyticsContent(analytics: state.analytics!),
            ],
          );
        },
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final AdminAnalyticsPeriod selected;
  final ValueChanged<AdminAnalyticsPeriod> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: AdminAnalyticsPeriod.values.map((p) {
          final sel = selected == p;
          return GestureDetector(
            onTap: () => onChanged(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.electricViolet
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _label(p),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(AdminAnalyticsPeriod p) => switch (p) {
        AdminAnalyticsPeriod.today => 'Today',
        AdminAnalyticsPeriod.last7Days => '7 Days',
        AdminAnalyticsPeriod.last30Days => '30 Days',
        AdminAnalyticsPeriod.last90Days => '90 Days',
        AdminAnalyticsPeriod.lastYear => '1 Year',
      };
}

class _AnalyticsContent extends StatelessWidget {
  final AdminPlatformAnalytics analytics;

  const _AnalyticsContent({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // KPI row
          if (analytics.kpis.isNotEmpty) ...[
            Text(
              'Key Metrics',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: analytics.kpis.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final kpi = analytics.kpis[i];
                  return SizedBox(
                    width: 150,
                    child: AdminStatCard(
                      label: kpi.label,
                      value: _formatValue(kpi.value, kpi.unit),
                      icon: Icons.analytics_rounded,
                      color: kpi.isGrowing
                          ? AppColors.neonTeal
                          : AppColors.vibrantCoral,
                      changePercent: kpi.changePercent,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // User stats grid
          Text(
            'Users',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              AdminStatCard(
                label: 'Total Users',
                value: _fmt(analytics.totalUsers),
                icon: Icons.people_alt_rounded,
                color: AppColors.electricViolet,
              ),
              AdminStatCard(
                label: 'New Users',
                value: _fmt(analytics.newUsers),
                icon: Icons.person_add_rounded,
                color: AppColors.neonTeal,
              ),
              AdminStatCard(
                label: 'Active Users',
                value: _fmt(analytics.activeUsers),
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF4CAF50),
              ),
              AdminStatCard(
                label: 'Total Creators',
                value: _fmt(analytics.totalCreators),
                icon: Icons.brush_rounded,
                color: const Color(0xFFFFB020),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User growth chart
          if (analytics.userGrowthTimeline.isNotEmpty) ...[
            Text(
              'User Growth',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _ChartCard(
              child: SizedBox(
                height: 140,
                child: AdminBarChart(
                  data: analytics.userGrowthTimeline,
                  color: AppColors.electricViolet,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Booking stats
          Text(
            'Bookings & Revenue',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              AdminStatCard(
                label: 'Total Revenue',
                value: '₹${_fmt(analytics.totalRevenue.toInt())}',
                icon: Icons.currency_rupee_rounded,
                color: const Color(0xFF4CAF50),
              ),
              AdminStatCard(
                label: 'Completion Rate',
                value: '${analytics.bookingCompletionRate.toStringAsFixed(1)}%',
                icon: Icons.check_circle_rounded,
                color: AppColors.neonTeal,
              ),
              AdminStatCard(
                label: 'Total Bookings',
                value: _fmt(analytics.totalBookings),
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFFFFB020),
              ),
              AdminStatCard(
                label: 'Avg Booking',
                value: '₹${analytics.averageBookingValue.toStringAsFixed(0)}',
                icon: Icons.receipt_rounded,
                color: AppColors.electricViolet,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue chart
          if (analytics.revenueTimeline.isNotEmpty) ...[
            Text(
              'Revenue Timeline',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _ChartCard(
              child: SizedBox(
                height: 140,
                child: AdminLineChart(
                  data: analytics.revenueTimeline,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Support stats
          Text(
            'Support',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              AdminStatCard(
                label: 'Open Disputes',
                value: _fmt(analytics.openDisputes),
                icon: Icons.gavel_rounded,
                color: AppColors.vibrantCoral,
              ),
              AdminStatCard(
                label: 'Resolution Rate',
                value: '${analytics.disputeResolutionRate.toStringAsFixed(1)}%',
                icon: Icons.check_rounded,
                color: AppColors.neonTeal,
              ),
              AdminStatCard(
                label: 'Pending Verif.',
                value: _fmt(analytics.pendingVerifications),
                icon: Icons.verified_rounded,
                color: const Color(0xFFFFB020),
              ),
              AdminStatCard(
                label: 'Open Reports',
                value: _fmt(analytics.openReports),
                icon: Icons.flag_rounded,
                color: const Color(0xFFFF8C42),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  String _formatValue(double v, String? unit) {
    if (unit == '₹' || unit == 'INR') {
      return '₹${_fmt(v.toInt())}';
    }
    if (unit == '%') return '${v.toStringAsFixed(1)}%';
    return _fmt(v.toInt());
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }
}
