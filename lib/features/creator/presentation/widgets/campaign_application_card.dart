import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/creator/domain/entities/campaign_application_entity.dart';

class CampaignApplicationCard extends StatelessWidget {
  const CampaignApplicationCard({
    super.key,
    required this.application,
    this.onTap,
    this.onWithdraw,
  });

  final CampaignApplicationEntity application;
  final VoidCallback? onTap;
  final VoidCallback? onWithdraw;

  Color get _statusColor {
    return switch (application.status) {
      ApplicationStatus.pending => Colors.orange,
      ApplicationStatus.accepted => Colors.green,
      ApplicationStatus.rejected => Colors.red,
      ApplicationStatus.withdrawn => Colors.grey,
    };
  }

  String get _statusLabel {
    return switch (application.status) {
      ApplicationStatus.pending => 'Pending',
      ApplicationStatus.accepted => 'Accepted',
      ApplicationStatus.rejected => 'Rejected',
      ApplicationStatus.withdrawn => 'Withdrawn',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: application.businessLogoUrl != null
                        ? NetworkImage(application.businessLogoUrl!)
                        : null,
                    child: application.businessLogoUrl == null
                        ? Text(application.businessName[0].toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(application.campaignTitle,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(application.businessName,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel,
                        style: TextStyle(
                            color: _statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.currency_rupee_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Proposed: ${application.currency} ${application.proposedRate.toStringAsFixed(0)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(application.appliedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              if (application.coverLetter != null &&
                  application.coverLetter!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  application.coverLetter!,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (application.isPending && onWithdraw != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onWithdraw,
                    style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error),
                    child: const Text('Withdraw'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
