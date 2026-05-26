import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, this.label = 'or continue with'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Divider(color: theme.colorScheme.outlineVariant, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: theme.colorScheme.outlineVariant, thickness: 1),
        ),
      ],
    );
  }
}
