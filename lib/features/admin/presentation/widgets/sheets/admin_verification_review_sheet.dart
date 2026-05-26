import 'package:flutter/material.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';

class AdminVerificationReviewSheet extends StatefulWidget {
  final AdminVerification verification;
  final void Function(VerificationStatus decision, String? note, String? rejectionReason) onSubmit;

  const AdminVerificationReviewSheet({
    super.key,
    required this.verification,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminVerification verification,
    required void Function(VerificationStatus, String?, String?) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminVerificationReviewSheet(
        verification: verification,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<AdminVerificationReviewSheet> createState() =>
      _AdminVerificationReviewSheetState();
}

class _AdminVerificationReviewSheetState
    extends State<AdminVerificationReviewSheet> {
  VerificationStatus? _decision;
  final _noteCtrl = TextEditingController();
  final _rejectReasonCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    _rejectReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPad),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Review Verification',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.verification.userName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Documents',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.verification.documents.map(
              (doc) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.type,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (doc.expiryDate != null)
                            Text(
                              'Expires ${doc.expiryDate!.year}-${doc.expiryDate!.month.toString().padLeft(2, '0')}-${doc.expiryDate!.day.toString().padLeft(2, '0')}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Color(0xFF7B2FFF),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Decision',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _DecisionButton(
                  label: 'Approve',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF00D9C0),
                  selected: _decision == VerificationStatus.approved,
                  onTap: () =>
                      setState(() => _decision = VerificationStatus.approved),
                ),
                const SizedBox(width: 10),
                _DecisionButton(
                  label: 'Reject',
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFFF5C6B),
                  selected: _decision == VerificationStatus.rejected,
                  onTap: () =>
                      setState(() => _decision = VerificationStatus.rejected),
                ),
                const SizedBox(width: 10),
                _DecisionButton(
                  label: 'More Info',
                  icon: Icons.help_rounded,
                  color: const Color(0xFFFFB020),
                  selected: _decision == VerificationStatus.needsMoreInfo,
                  onTap: () => setState(
                    () => _decision = VerificationStatus.needsMoreInfo,
                  ),
                ),
              ],
            ),
            if (_decision == VerificationStatus.rejected) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _rejectReasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Internal note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Submit Decision',
              onPressed: _decision != null
                  ? () {
                      widget.onSubmit(
                        _decision!,
                        _noteCtrl.text.trim().isEmpty
                            ? null
                            : _noteCtrl.text.trim(),
                        _rejectReasonCtrl.text.trim().isEmpty
                            ? null
                            : _rejectReasonCtrl.text.trim(),
                      );
                      Navigator.pop(context);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? Colors.white : color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
