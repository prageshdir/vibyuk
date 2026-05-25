import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

enum PasswordStrength { none, weak, fair, strong, veryStrong }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  PasswordStrength get _strength {
    if (password.isEmpty) return PasswordStrength.none;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    return switch (score) {
      0 || 1 => PasswordStrength.weak,
      2 => PasswordStrength.fair,
      3 => PasswordStrength.strong,
      _ => PasswordStrength.veryStrong,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = _strength;

    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final isActive = index < _strengthLevel(strength);
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isActive ? _strengthColor(strength) : theme.colorScheme.outlineVariant,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _strengthLabel(strength),
          style: theme.textTheme.labelSmall?.copyWith(
            color: _strengthColor(strength),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _strengthLevel(PasswordStrength s) => switch (s) {
        PasswordStrength.none => 0,
        PasswordStrength.weak => 1,
        PasswordStrength.fair => 2,
        PasswordStrength.strong => 3,
        PasswordStrength.veryStrong => 4,
      };

  Color _strengthColor(PasswordStrength s) => switch (s) {
        PasswordStrength.none => Colors.transparent,
        PasswordStrength.weak => AppColors.error,
        PasswordStrength.fair => AppColors.warning,
        PasswordStrength.strong => AppColors.success,
        PasswordStrength.veryStrong => const Color(0xFF00897B),
      };

  String _strengthLabel(PasswordStrength s) => switch (s) {
        PasswordStrength.none => '',
        PasswordStrength.weak => 'Weak',
        PasswordStrength.fair => 'Fair',
        PasswordStrength.strong => 'Strong',
        PasswordStrength.veryStrong => 'Very strong',
      };
}
