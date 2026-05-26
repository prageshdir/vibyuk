import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RefundDialog extends StatefulWidget {
  final String ticketId;
  final String ticketTypeName;
  final double amount;
  final String currency;
  final void Function(String reason) onConfirm;

  const RefundDialog({
    super.key,
    required this.ticketId,
    required this.ticketTypeName,
    required this.amount,
    required this.currency,
    required this.onConfirm,
  });

  @override
  State<RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends State<RefundDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatAmount() {
    final symbol = switch (widget.currency) {
      'USD' => '\$',
      'INR' => '₹',
      _ => widget.currency,
    };
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2)
        .format(widget.amount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Request Refund'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.ticketTypeName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    _formatAmount(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for refund',
                hintText: 'Please describe why you are requesting a refund...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return 'Please provide at least 10 characters';
                }
                return null;
              },
              onChanged: (_) {
                final valid = _formKey.currentState?.validate() ?? false;
                if (valid != _isValid) setState(() => _isValid = valid);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Refunds may take 5–10 business days to process.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _isValid ? Colors.red.shade600 : null,
          ),
          onPressed: _isValid
              ? () {
                  if (_formKey.currentState?.validate() ?? false) {
                    widget.onConfirm(_reasonController.text.trim());
                    Navigator.of(context).pop();
                  }
                }
              : null,
          child: const Text('Request Refund'),
        ),
      ],
    );
  }
}
