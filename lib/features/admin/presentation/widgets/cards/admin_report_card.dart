import 'package:flutter/material.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_status_badge.dart';

class AdminReportCard extends StatelessWidget {
  final AdminReport report;
  final VoidCallback onTap;

  const AdminReportCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrgent = report.requiresUrgentReview;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent
                ? const Color(0xFFFF5C6B).withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryIcon(category: report.category),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.targetUserName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'by ${report.reportedByUserName}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(report.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _CategoryBadge(category: report.category),
                const SizedBox(width: 8),
                if (report.similarReportsCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB020).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${report.similarReportsCount} similar',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB020),
                      ),
                    ),
                  ),
                if (report.isRepeatOffender) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5C6B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Repeat',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF5C6B),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${report.daysPending}d ago',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(ReportStatus status) => switch (status) {
        ReportStatus.pending => AdminStatusBadge.warning('Pending'),
        ReportStatus.underReview => AdminStatusBadge.info('In Review'),
        ReportStatus.actionTaken => AdminStatusBadge.success('Actioned'),
        ReportStatus.dismissed => AdminStatusBadge.neutral('Dismissed'),
        ReportStatus.escalated => AdminStatusBadge.danger('Escalated'),
      };
}

class _CategoryIcon extends StatelessWidget {
  final ReportCategory category;
  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (category) {
      ReportCategory.inappropriateContent =>
        (Icons.block_rounded, const Color(0xFFFF5C6B)),
      ReportCategory.fraud =>
        (Icons.security_rounded, const Color(0xFFFF5C6B)),
      ReportCategory.harassment =>
        (Icons.person_off_rounded, const Color(0xFFFF8C42)),
      ReportCategory.spam =>
        (Icons.mail_outline_rounded, const Color(0xFFFFB020)),
      ReportCategory.fakeProfile =>
        (Icons.badge_outlined, const Color(0xFF7B2FFF)),
      ReportCategory.copyright =>
        (Icons.copyright_rounded, const Color(0xFF00D9C0)),
      ReportCategory.other =>
        (Icons.help_outline_rounded, Colors.grey),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final ReportCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final label = switch (category) {
      ReportCategory.inappropriateContent => 'Inappropriate',
      ReportCategory.fraud => 'Fraud',
      ReportCategory.harassment => 'Harassment',
      ReportCategory.spam => 'Spam',
      ReportCategory.fakeProfile => 'Fake Profile',
      ReportCategory.copyright => 'Copyright',
      ReportCategory.other => 'Other',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}
