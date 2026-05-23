import 'package:flutter/material.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/buttons/secondary_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content ??
          (message != null
              ? Text(message!, style: Theme.of(context).textTheme.bodyMedium)
              : null),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (cancelLabel != null)
          Expanded(
            child: SecondaryButton(
              label: cancelLabel!,
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
            ),
          ),
        if (cancelLabel != null && confirmLabel != null) const SizedBox(width: 12),
        if (confirmLabel != null)
          Expanded(
            child: PrimaryButton(
              label: confirmLabel!,
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
            ),
          ),
      ],
    );
  }
}
