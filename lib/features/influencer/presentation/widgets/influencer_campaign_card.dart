import 'package:flutter/material.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';

class InfluencerCampaignCard extends StatelessWidget {
  const InfluencerCampaignCard({
    super.key,
    required this.campaign,
    required this.onReviewDeliverable,
  });

  final InfluencerCampaignEntity campaign;
  final void Function(ContentDeliverableEntity) onReviewDeliverable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingCount = campaign.pendingDeliverables;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(campaign.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                _StatusChip(status: campaign.status),
              ],
            ),
            const SizedBox(height: 6),
            _MetaRow(campaign: campaign),
            if (campaign.platforms.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PlatformChips(platforms: campaign.platforms),
            ],
            if (campaign.analytics != null) ...[
              const SizedBox(height: 12),
              _AnalyticsSummary(analytics: campaign.analytics!),
            ],
            if (pendingCount > 0) ...[
              const SizedBox(height: 12),
              _PendingDeliverables(
                deliverables: campaign.deliverables
                    .where((d) =>
                        d.status == DeliverableStatus.submitted ||
                        d.status == DeliverableStatus.underReview)
                    .toList(),
                onReview: onReviewDeliverable,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final InfluencerCampaignStatus status;

  Color _color(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (status) {
      InfluencerCampaignStatus.draft => cs.outline,
      InfluencerCampaignStatus.published => cs.primary,
      InfluencerCampaignStatus.applications => Colors.orange,
      InfluencerCampaignStatus.inProgress => Colors.green,
      InfluencerCampaignStatus.completed => cs.tertiary,
      InfluencerCampaignStatus.archived => cs.outlineVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.campaign});
  final InfluencerCampaignEntity campaign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Wrap(
      spacing: 16,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.currency_rupee, size: 13),
          Text(campaign.budgetDisplay.replaceAll('₹', ''), style: style),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.people_alt_outlined, size: 13),
          const SizedBox(width: 2),
          Text('${campaign.confirmedCount}/${campaign.maxInfluencers} influencers',
              style: style),
        ]),
        if (campaign.minFollowers != null)
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.bar_chart_outlined, size: 13),
            const SizedBox(width: 2),
            Text('${_formatK(campaign.minFollowers!)}+ followers', style: style),
          ]),
      ],
    );
  }

  String _formatK(int n) => n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}M'
      : n >= 1000
          ? '${(n / 1000).toStringAsFixed(0)}K'
          : '$n';
}

class _PlatformChips extends StatelessWidget {
  const _PlatformChips({required this.platforms});
  final List<InfluencerPlatform> platforms;

  IconData _iconFor(InfluencerPlatform p) => switch (p) {
        InfluencerPlatform.instagram => Icons.camera_alt_outlined,
        InfluencerPlatform.youtube => Icons.play_circle_outline,
        InfluencerPlatform.tiktok => Icons.music_note_outlined,
        InfluencerPlatform.twitter => Icons.tag,
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: platforms
          .map((p) => Chip(
                avatar: Icon(_iconFor(p), size: 14),
                label: Text(p.label,
                    style: const TextStyle(fontSize: 11)),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }
}

class _AnalyticsSummary extends StatelessWidget {
  const _AnalyticsSummary({required this.analytics});
  final InfluencerCampaignAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AnalyticsMetric(
              label: 'Reach', value: _formatK(analytics.totalReach)),
          _AnalyticsMetric(
              label: 'Impressions',
              value: _formatK(analytics.totalImpressions)),
          _AnalyticsMetric(label: 'CPM', value: analytics.cpmDisplay),
          _AnalyticsMetric(label: 'ROI', value: analytics.roiDisplay),
        ],
      ),
    );
  }

  String _formatK(int n) => n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}M'
      : n >= 1000
          ? '${(n / 1000).toStringAsFixed(0)}K'
          : '$n';
}

class _AnalyticsMetric extends StatelessWidget {
  const _AnalyticsMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _PendingDeliverables extends StatelessWidget {
  const _PendingDeliverables({
    required this.deliverables,
    required this.onReview,
  });
  final List<ContentDeliverableEntity> deliverables;
  final void Function(ContentDeliverableEntity) onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pending_actions_outlined,
                size: 14, color: Colors.orange.shade700),
            const SizedBox(width: 6),
            Text(
              '${deliverables.length} deliverable${deliverables.length == 1 ? '' : 's'} awaiting review',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...deliverables.map((d) => _DeliverableRow(
              deliverable: d,
              onReview: () => onReview(d),
            )),
      ],
    );
  }
}

class _DeliverableRow extends StatelessWidget {
  const _DeliverableRow({required this.deliverable, required this.onReview});
  final ContentDeliverableEntity deliverable;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deliverable.influencerName,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(deliverable.type.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          TextButton(
            onPressed: onReview,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}
