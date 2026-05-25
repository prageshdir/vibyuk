import 'package:flutter/material.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';

class AdminUserActionSheet extends StatefulWidget {
  final AdminUser user;
  final void Function(ModerationAction action, String? reason, Duration? duration, String? note) onSubmit;

  const AdminUserActionSheet({
    super.key,
    required this.user,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminUser user,
    required void Function(ModerationAction, String?, Duration?, String?) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminUserActionSheet(user: user, onSubmit: onSubmit),
    );
  }

  @override
  State<AdminUserActionSheet> createState() => _AdminUserActionSheetState();
}

class _AdminUserActionSheetState extends State<AdminUserActionSheet> {
  ModerationAction? _selectedAction;
  final _reasonCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  int _suspensionDays = 7;

  @override
  void dispose() {
    _reasonCtrl.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moderate ${widget.user.displayName}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Action',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _ActionGrid(
                  selected: _selectedAction,
                  onSelect: (a) => setState(() => _selectedAction = a),
                ),
                if (_selectedAction != null) ...[
                  const SizedBox(height: 16),
                  if (_selectedAction == ModerationAction.suspend) ...[
                    Text(
                      'Suspension Duration',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [7, 14, 30, 90].map((days) {
                        final sel = _suspensionDays == days;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _suspensionDays = days),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFF7B2FFF)
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${days}d',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: sel
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reason (visible to user)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Internal note',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Apply Action',
                    onPressed: _submit,
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_selectedAction == null) return;
    widget.onSubmit(
      _selectedAction!,
      _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
      _selectedAction == ModerationAction.suspend
          ? Duration(days: _suspensionDays)
          : null,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    Navigator.pop(context);
  }
}

class _ActionGrid extends StatelessWidget {
  final ModerationAction? selected;
  final ValueChanged<ModerationAction> onSelect;

  const _ActionGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (ModerationAction.warn, 'Warn', Icons.warning_amber_rounded, const Color(0xFFFFB020)),
      (ModerationAction.suspend, 'Suspend', Icons.block_rounded, const Color(0xFFFF8C42)),
      (ModerationAction.ban, 'Ban', Icons.gavel_rounded, const Color(0xFFFF5C6B)),
      (ModerationAction.unban, 'Unban', Icons.check_circle_outline_rounded, const Color(0xFF00D9C0)),
      (ModerationAction.resetTrustScore, 'Reset Trust', Icons.refresh_rounded, const Color(0xFF7B2FFF)),
      (ModerationAction.verifyManually, 'Verify', Icons.verified_rounded, const Color(0xFF4CAF50)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((a) {
        final (action, label, icon, color) = a;
        final sel = selected == action;
        return GestureDetector(
          onTap: () => onSelect(action),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? color : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? color : color.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: sel ? Colors.white : color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: sel ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
