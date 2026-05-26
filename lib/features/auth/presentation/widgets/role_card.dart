import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';

class RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryContainer,
                    AppColors.primaryContainer.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _iconGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(_icon, color: Colors.white, size: 26),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              role.displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _features
                  .map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (role) {
        UserRole.creator => Icons.brush_rounded,
        UserRole.business => Icons.business_rounded,
      };

  List<Color> get _iconGradient => switch (role) {
        UserRole.creator => AppColors.creatorGradient,
        UserRole.business => [AppColors.secondary, AppColors.secondaryDark],
      };

  String get _description => switch (role) {
        UserRole.creator =>
          'Showcase your talent, offer services, and connect with brands looking for creators like you.',
        UserRole.business =>
          'Discover and book creators for your events, campaigns, and brand collaborations.',
      };

  List<String> get _features => switch (role) {
        UserRole.creator => ['Portfolio', 'Bookings', 'Earnings', 'Analytics'],
        UserRole.business => ['Find Creators', 'Event Planning', 'Contracts', 'Reports'],
      };
}
