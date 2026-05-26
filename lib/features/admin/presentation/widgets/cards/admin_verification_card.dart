import 'package:flutter/material.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_status_badge.dart';

class AdminVerificationCard extends StatelessWidget {
  final AdminVerification verification;
  final VoidCallback onTap;

  const AdminVerificationCard({
    super.key,
    required this.verification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF00D9C0).withValues(alpha: 0.15),
              backgroundImage: verification.userAvatarUrl != null
                  ? NetworkImage(verification.userAvatarUrl!)
                  : null,
              child: verification.userAvatarUrl == null
                  ? Text(
                      verification.userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF00D9C0),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          verification.userName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusBadge(verification.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _TypeChip(type: verification.type),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.description_outlined,
                        size: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${verification.documents.length} doc${verification.documents.length != 1 ? 's' : ''}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${verification.daysPending}d',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: verification.daysPending > 3
                              ? const Color(0xFFFFB020)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: verification.daysPending > 3
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF7B2FFF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(VerificationStatus status) => switch (status) {
        VerificationStatus.pending => AdminStatusBadge.warning('Pending'),
        VerificationStatus.underReview => AdminStatusBadge.info('In Review'),
        VerificationStatus.approved => AdminStatusBadge.success('Approved'),
        VerificationStatus.rejected => AdminStatusBadge.danger('Rejected'),
        VerificationStatus.needsMoreInfo => AdminStatusBadge.neutral('More Info'),
      };
}

class _TypeChip extends StatelessWidget {
  final VerificationType type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      VerificationType.identity => ('ID', const Color(0xFF7B2FFF)),
      VerificationType.business => ('Business', const Color(0xFF00D9C0)),
      VerificationType.portfolio => ('Portfolio', const Color(0xFFFFB020)),
      VerificationType.bankAccount => ('Bank', const Color(0xFF4CAF50)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
