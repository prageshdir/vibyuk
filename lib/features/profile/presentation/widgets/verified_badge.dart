import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Verified creator',
      child: Icon(
        Icons.verified_rounded,
        size: size,
        color: AppColors.primary,
      ),
    );
  }
}
