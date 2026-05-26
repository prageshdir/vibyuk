import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

enum AdminBadgeStyle { filled, outlined, subtle }

class AdminStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final AdminBadgeStyle style;
  final IconData? icon;

  const AdminStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.style = AdminBadgeStyle.subtle,
    this.icon,
  });

  factory AdminStatusBadge.success(String label) => AdminStatusBadge(
        label: label,
        color: AppColors.neonTeal,
        icon: Icons.check_circle_rounded,
      );

  factory AdminStatusBadge.warning(String label) => AdminStatusBadge(
        label: label,
        color: const Color(0xFFFFB020),
        icon: Icons.warning_amber_rounded,
      );

  factory AdminStatusBadge.danger(String label) => AdminStatusBadge(
        label: label,
        color: AppColors.vibrantCoral,
        icon: Icons.error_rounded,
      );

  factory AdminStatusBadge.info(String label) => AdminStatusBadge(
        label: label,
        color: AppColors.electricViolet,
        icon: Icons.info_rounded,
      );

  factory AdminStatusBadge.neutral(String label) => AdminStatusBadge(
        label: label,
        color: Colors.grey,
      );

  @override
  Widget build(BuildContext context) {
    final bg = style == AdminBadgeStyle.filled
        ? color
        : color.withValues(alpha: 0.12);
    final fg = style == AdminBadgeStyle.filled ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: style == AdminBadgeStyle.outlined
            ? Border.all(color: color, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
