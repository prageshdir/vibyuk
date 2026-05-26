import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';

class CampaignBanner extends StatelessWidget {
  const CampaignBanner({
    super.key,
    required this.campaign,
    this.onTap,
  });

  final TourismCampaignEntity campaign;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverImage(),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(context),
                  const SizedBox(height: 8),
                  Text(
                    campaign.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    campaign.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  _buildHashtags(context),
                  const SizedBox(height: 10),
                  _buildEnrollmentProgress(context),
                  const SizedBox(height: 8),
                  _buildStats(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: campaign.coverImageUrl != null
            ? CachedNetworkImage(
                imageUrl: campaign.coverImageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.shimmerBase),
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.brandGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.campaign, color: Colors.white38, size: 48),
      );

  Widget _buildStatusBadge(BuildContext context) {
    final (label, color) = switch (campaign.status) {
      CampaignStatus.active ||
      CampaignStatus.published ||
      CampaignStatus.applications ||
      CampaignStatus.inProgress =>
        ('ACTIVE', AppColors.success),
      CampaignStatus.draft => ('DRAFT', AppColors.outline),
      CampaignStatus.completed || CampaignStatus.archived => ('COMPLETED', AppColors.textSecondary),
      CampaignStatus.paused => ('PAUSED', AppColors.warning),
      CampaignStatus.cancelled => ('CANCELLED', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildHashtags(BuildContext context) {
    if (campaign.hashtags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: campaign.hashtags.take(4).map((tag) {
        return Text(
          '#$tag',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnrollmentProgress(BuildContext context) {
    final progress = campaign.enrollmentProgress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Creator Enrollment',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '${campaign.enrolledCreatorCount}/${campaign.targetCreatorCount}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.visibility_outlined,
          value: campaign.formattedReach,
          label: 'Reach',
        ),
        const SizedBox(width: 16),
        _StatItem(
          icon: Icons.trending_up,
          value: '${campaign.engagementRate.toStringAsFixed(1)}%',
          label: 'Engagement',
        ),
        const Spacer(),
        if (campaign.isActive)
          Text(
            '${campaign.daysRemaining}d left',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: campaign.daysRemaining < 7
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textSecondary, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
