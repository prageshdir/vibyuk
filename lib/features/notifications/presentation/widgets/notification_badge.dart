import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_badge/notification_badge_cubit.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final double? top;
  final double? right;

  const NotificationBadge({
    super.key,
    required this.child,
    this.top = 0,
    this.right = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBadgeCubit, int>(
      builder: (context, count) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (count > 0)
              Positioned(
                top: top,
                right: right,
                child: _BadgeCount(count: count),
              ),
          ],
        );
      },
    );
  }
}

class _BadgeCount extends StatelessWidget {
  final int count;

  const _BadgeCount({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.onSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
