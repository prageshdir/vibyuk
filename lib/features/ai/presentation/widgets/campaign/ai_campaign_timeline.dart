import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';
import 'ai_campaign_step_card.dart';

class AiCampaignTimeline extends StatelessWidget {
  final AiCampaign campaign;
  final void Function(String stepId, CampaignStepStatus status)? onUpdateStep;

  const AiCampaignTimeline({
    super.key,
    required this.campaign,
    this.onUpdateStep,
  });

  @override
  Widget build(BuildContext context) {
    final sortedSteps = [...campaign.steps]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress summary
        _ProgressBar(campaign: campaign),
        const SizedBox(height: 20),

        // Steps
        ...sortedSteps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          return AiCampaignStepCard(
            key: ValueKey(step.id),
            step: step,
            isFirst: i == 0,
            isLast: i == sortedSteps.length - 1,
            onMarkComplete: onUpdateStep != null
                ? () => onUpdateStep!(step.id, CampaignStepStatus.completed)
                : null,
          );
        }),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final AiCampaign campaign;

  const _ProgressBar({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final progress = campaign.progressPercent;
    final completed = campaign.completedSteps;
    final total = campaign.steps.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.tertiary.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Campaign Progress',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                '$completed / $total steps',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(
                progress >= 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatChip(
                label: 'Est. ROI',
                value: '${campaign.estimatedRoi.toStringAsFixed(0)}%',
                color: AppColors.success,
              ),
              _StatChip(
                label: 'Budget',
                value: '₹${campaign.budget.toStringAsFixed(0)}',
                color: AppColors.primary,
              ),
              _StatChip(
                label: 'Reach',
                value: _formatNumber(campaign.estimatedReach),
                color: AppColors.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
