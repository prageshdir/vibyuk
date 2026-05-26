import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';

class AiCampaignStepCard extends StatelessWidget {
  final AiCampaignStep step;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onTap;

  const AiCampaignStepCard({
    super.key,
    required this.step,
    this.isFirst = false,
    this.isLast = false,
    this.onMarkComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeConfig = _StepTypeConfig.from(step.stepType);
    final statusConfig = _StatusConfig.from(step.status);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: AppColors.outline.withOpacity(0.3),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusConfig.color.withOpacity(0.12),
                    border: Border.all(
                      color: statusConfig.color.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    statusConfig.icon,
                    size: 15,
                    color: statusConfig.color,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: AppColors.outline.withOpacity(0.3),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: step.status == CampaignStepStatus.inProgress
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.outline.withOpacity(0.12),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: typeConfig.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(typeConfig.icon,
                                  size: 11, color: typeConfig.color),
                              const SizedBox(width: 4),
                              Text(
                                typeConfig.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: typeConfig.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(step.scheduledDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        decoration: step.status == CampaignStepStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        Text(
                          '₹${step.estimatedCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (step.assignedCreatorName != null) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.person_outline_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            step.assignedCreatorName!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (step.status == CampaignStepStatus.pending &&
                            onMarkComplete != null)
                          GestureDetector(
                            onTap: onMarkComplete,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.brandGradient,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Mark Done',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _StepTypeConfig {
  final Color color;
  final IconData icon;
  final String label;

  const _StepTypeConfig({
    required this.color,
    required this.icon,
    required this.label,
  });

  factory _StepTypeConfig.from(CampaignStepType type) {
    return switch (type) {
      CampaignStepType.content => _StepTypeConfig(
          color: AppColors.primary,
          icon: Icons.video_library_outlined,
          label: 'Content',
        ),
      CampaignStepType.outreach => _StepTypeConfig(
          color: AppColors.tertiary,
          icon: Icons.connect_without_contact_outlined,
          label: 'Outreach',
        ),
      CampaignStepType.event => _StepTypeConfig(
          color: AppColors.secondary,
          icon: Icons.event_outlined,
          label: 'Event',
        ),
      CampaignStepType.social => _StepTypeConfig(
          color: const Color(0xFF4267B2),
          icon: Icons.share_outlined,
          label: 'Social',
        ),
      CampaignStepType.email => _StepTypeConfig(
          color: AppColors.warning,
          icon: Icons.mail_outline_rounded,
          label: 'Email',
        ),
      CampaignStepType.paid => _StepTypeConfig(
          color: AppColors.success,
          icon: Icons.ads_click_rounded,
          label: 'Paid Ads',
        ),
    };
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;

  const _StatusConfig({required this.color, required this.icon});

  factory _StatusConfig.from(CampaignStepStatus status) {
    return switch (status) {
      CampaignStepStatus.completed => _StatusConfig(
          color: AppColors.success,
          icon: Icons.check_rounded,
        ),
      CampaignStepStatus.inProgress => _StatusConfig(
          color: AppColors.primary,
          icon: Icons.play_arrow_rounded,
        ),
      CampaignStepStatus.skipped => _StatusConfig(
          color: AppColors.textSecondary,
          icon: Icons.skip_next_rounded,
        ),
      CampaignStepStatus.pending => _StatusConfig(
          color: AppColors.outline,
          icon: Icons.radio_button_unchecked_rounded,
        ),
    };
  }
}
