import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
  });

  final OnboardingStep currentStep;

  static const List<_StepInfo> _steps = [
    _StepInfo(OnboardingStep.basicInfo, Icons.person_outline_rounded, 'Profile'),
    _StepInfo(OnboardingStep.portfolio, Icons.photo_library_outlined, 'Portfolio'),
    _StepInfo(OnboardingStep.pricing, Icons.sell_outlined, 'Pricing'),
    _StepInfo(OnboardingStep.availability, Icons.calendar_month_outlined, 'Availability'),
  ];

  int get _currentIndex {
    return _steps.indexWhere((s) => s.step == currentStep).clamp(0, _steps.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final idx = _currentIndex;

    return Column(
      children: [
        // Step dots + connector
        Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepIdx = i ~/ 2;
              final completed = stepIdx < idx;
              return Expanded(
                child: Container(
                  height: 2,
                  color: completed ? AppColors.primary : theme.colorScheme.outlineVariant,
                ),
              );
            }
            final stepIdx = i ~/ 2;
            final isActive = stepIdx == idx;
            final completed = stepIdx < idx;
            return _StepDot(
              icon: _steps[stepIdx].icon,
              isActive: isActive,
              isCompleted: completed,
            );
          }),
        ),
        const SizedBox(height: 8),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _steps.asMap().entries.map((e) {
            final isActive = e.key == idx;
            final completed = e.key < idx;
            return Text(
              e.value.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: (isActive || completed)
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.icon,
    required this.isActive,
    required this.isCompleted,
  });

  final IconData icon;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 36 : 28,
      height: isActive ? 36 : 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? Colors.green
            : isActive
                ? AppColors.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1)
              ]
            : null,
      ),
      child: Icon(
        isCompleted ? Icons.check_rounded : icon,
        size: isActive ? 18 : 14,
        color: (isActive || isCompleted) ? Colors.white : Colors.grey,
      ),
    );
  }
}

class _StepInfo {
  const _StepInfo(this.step, this.icon, this.label);
  final OnboardingStep step;
  final IconData icon;
  final String label;
}
