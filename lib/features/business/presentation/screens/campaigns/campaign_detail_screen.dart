import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/campaign/campaign_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;
  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<CampaignBloc>()
        .add(LoadCampaignDetailEvent(campaignId: widget.campaignId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CampaignBloc, CampaignState>(
      listener: (context, state) {
        if (state is CampaignPublishedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campaign published!')),
          );
        }
        if (state is CampaignDeletedState) {
          context.pop();
        }
      },
      builder: (context, state) {
        if (state is CampaignLoadingState) {
          return const Scaffold(body: Center(child: AppLoader()));
        }

        CampaignEntity? campaign;
        if (state is CampaignDetailLoadedState) {
          campaign = state.campaign;
        } else if (state is CampaignPublishedState) {
          campaign = state.campaign;
        } else if (state is CampaignUpdatedState) {
          campaign = state.campaign;
        }

        if (campaign == null) {
          return Scaffold(
            appBar: AppBar(),
            body: BusinessEmptyState(
              title: 'Campaign not found',
              icon: Icons.campaign_rounded,
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            ),
          );
        }

        return _CampaignDetailView(campaign: campaign);
      },
    );
  }
}

class _CampaignDetailView extends StatelessWidget {
  final CampaignEntity campaign;
  const _CampaignDetailView({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = campaign.metrics;

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (campaign.canPublish)
            TextButton(
              onPressed: () => context
                  .read<CampaignBloc>()
                  .add(PublishCampaignEvent(campaignId: campaign.id)),
              child: const Text('Publish',
                  style: TextStyle(color: AppColors.success)),
            ),
          if (campaign.canEdit)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () =>
                  context.push('/campaigns/${campaign.id}/edit'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusAndDates(campaign: campaign),
            const SizedBox(height: 20),
            if (campaign.description != null) ...[
              Text(
                campaign.description!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
            ],
            _BudgetProgress(campaign: campaign),
            const SizedBox(height: 20),
            if (metrics != null) ...[
              Text(
                'Performance',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _MetricsGrid(metrics: metrics),
              const SizedBox(height: 20),
            ],
            if (campaign.categories.isNotEmpty) ...[
              Text(
                'Target Categories',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: campaign.categories.map((c) {
                  return Chip(
                    label: Text(c),
                    backgroundColor: AppColors.primaryContainer,
                    labelStyle: const TextStyle(
                        color: AppColors.primary, fontSize: 12),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusAndDates extends StatelessWidget {
  final CampaignEntity campaign;
  const _StatusAndDates({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (campaign.status) {
      CampaignStatus.active => (AppColors.successContainer, AppColors.success),
      CampaignStatus.draft =>
        (AppColors.surfaceVariant, AppColors.textSecondary),
      CampaignStatus.paused =>
        (AppColors.warningContainer, AppColors.warning),
      CampaignStatus.completed =>
        (AppColors.primaryContainer, AppColors.primary),
      CampaignStatus.cancelled =>
        (AppColors.errorContainer, AppColors.error),
    };

    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            campaign.status.label,
            style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('d MMM y').format(campaign.startDate),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            if (campaign.endDate != null)
              Text(
                '→ ${DateFormat('d MMM y').format(campaign.endDate!)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
      ],
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final CampaignEntity campaign;
  const _BudgetProgress({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Creators booked',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${campaign.bookedCount} / ${campaign.targetCreatorCount}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: campaign.bookingProgress,
                minHeight: 8,
                backgroundColor: AppColors.outlineVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  campaign.budgetDisplay,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final CampaignMetrics metrics;
  const _MetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _MetricCard(
          label: 'Impressions',
          value: _formatNum(metrics.impressions),
          icon: Icons.visibility_rounded,
          color: AppColors.primary,
        ),
        _MetricCard(
          label: 'Reach',
          value: _formatNum(metrics.reach),
          icon: Icons.people_rounded,
          color: AppColors.secondary,
        ),
        _MetricCard(
          label: 'Engagement',
          value: '${metrics.engagementRate.toStringAsFixed(1)}%',
          icon: Icons.favorite_rounded,
          color: AppColors.tertiary,
        ),
        _MetricCard(
          label: 'Conversions',
          value: '${metrics.conversions}',
          icon: Icons.shopping_cart_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }

  String _formatNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
