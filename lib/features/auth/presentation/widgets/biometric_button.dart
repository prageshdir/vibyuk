import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class BiometricButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const BiometricButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryContainer,
                  AppColors.primaryContainer.withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.fingerprint_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use Biometric',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
