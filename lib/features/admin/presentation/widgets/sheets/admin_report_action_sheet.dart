import 'package:flutter/material.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_status_badge.dart';

class AdminReportActionSheet extends StatefulWidget {
  final AdminReport report;
  final void Function(ReportActionType action, String? note) onSubmit;

  const AdminReportActionSheet({
    super.key,
    required this.report,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminReport report,
    required void Function(ReportActionType, String?) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AdminReportActionSheet(report: report, onSubmit: onSubmit),
    );
  }

  @override
  State<AdminReportActionSheet> createState() => _AdminReportActionSheetState();
}

class _AdminReportActionSheetState extends State<AdminReportActionSheet> {
  ReportActionType? _action;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Handle Report',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (widget.report.requiresUrgentReview)
                  AdminStatusBadge.danger('URGENT'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Against: ${widget.report.targetUserName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.report.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.report.evidenceUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${widget.report.evidenceUrls.length} evidence attachment(s)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF7B2FFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Select Action',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...ReportActionType.values.map((a) {
              final (label, icon, color) = _actionMeta(a);
              final sel = _action == a;
              return GestureDetector(
                onTap: () => setState(() => _action = a),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel ? color.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? color
                          : theme.colorScheme.outline.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: sel ? color : null,
                        ),
                      ),
                      const Spacer(),
                      if (sel)
                        Icon(Icons.check_circle_rounded, color: color, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Submit',
              onPressed: _action != null
                  ? () {
                      widget.onSubmit(
                        _action!,
                        _noteCtrl.text.trim().isEmpty
                            ? null
                            : _noteCtrl.text.trim(),
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

  (String, IconData, Color) _actionMeta(ReportActionType a) => switch (a) {
        ReportActionType.dismiss =>
          ('Dismiss Report', Icons.close_rounded, Colors.grey),
        ReportActionType.warnUser =>
          ('Warn User', Icons.warning_amber_rounded, const Color(0xFFFFB020)),
        ReportActionType.removeContent =>
          ('Remove Content', Icons.delete_outline_rounded, const Color(0xFFFF8C42)),
        ReportActionType.suspendUser =>
          ('Suspend User', Icons.block_rounded, const Color(0xFFFF5C6B)),
        ReportActionType.banUser =>
          ('Ban User', Icons.gavel_rounded, const Color(0xFFFF5C6B)),
        ReportActionType.escalate =>
          ('Escalate', Icons.priority_high_rounded, const Color(0xFF7B2FFF)),
      };
}
