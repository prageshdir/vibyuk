import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_insight.dart';

class AiInsightCard extends StatelessWidget {
  final AiInsight insight;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final bool isDismissing;

  const AiInsightCard({
    super.key,
    required this.insight,
    this.onAction,
    this.onDismiss,
    this.isDismissing = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _InsightConfig.from(insight);

    return AnimatedOpacity(
      opacity: isDismissing ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          border: Border.all(color: config.borderColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: config.accentColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Colored top bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: config.accentColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: config.accentColor.withOpacity(0.12),
                        ),
                        child: Icon(
                          config.icon,
                          size: 18,
                          color: config.accentColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _PriorityBadge(priority: insight.priority),
                                const SizedBox(width: 6),
                                _TypeBadge(type: insight.type),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (onDismiss != null)
                        GestureDetector(
                          onTap: isDismissing ? null : onDismiss,
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    insight.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (insight.impactScore != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Impact Score',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: insight.impactScore! / 100,
                              minHeight: 5,
                              backgroundColor: config.accentColor.withOpacity(0.12),
                              valueColor:
                                  AlwaysStoppedAnimation(config.accentColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${insight.impactScore!.toInt()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: config.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (insight.actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onAction,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: config.accentColor),
                          foregroundColor: config.accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          insight.actionLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final InsightPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      InsightPriority.critical => ('CRITICAL', AppColors.error),
      InsightPriority.high => ('HIGH', AppColors.secondary),
      InsightPriority.medium => ('MEDIUM', AppColors.warning),
      InsightPriority.low => ('LOW', AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final InsightType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      InsightType.opportunity => 'Opportunity',
      InsightType.warning => 'Warning',
      InsightType.achievement => 'Achievement',
      InsightType.trend => 'Trend',
      InsightType.recommendation => 'AI Pick',
    };

    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InsightConfig {
  final Color accentColor;
  final Color borderColor;
  final IconData icon;

  const _InsightConfig({
    required this.accentColor,
    required this.borderColor,
    required this.icon,
  });

  factory _InsightConfig.from(AiInsight insight) {
    return switch (insight.type) {
      InsightType.opportunity => _InsightConfig(
          accentColor: AppColors.success,
          borderColor: AppColors.success,
          icon: Icons.trending_up_rounded,
        ),
      InsightType.warning => _InsightConfig(
          accentColor: AppColors.warning,
          borderColor: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        ),
      InsightType.achievement => _InsightConfig(
          accentColor: AppColors.tertiary,
          borderColor: AppColors.tertiary,
          icon: Icons.emoji_events_rounded,
        ),
      InsightType.trend => _InsightConfig(
          accentColor: AppColors.primary,
          borderColor: AppColors.primary,
          icon: Icons.insights_rounded,
        ),
      InsightType.recommendation => _InsightConfig(
          accentColor: AppColors.secondary,
          borderColor: AppColors.secondary,
          icon: Icons.auto_awesome_rounded,
        ),
    };
  }
}
