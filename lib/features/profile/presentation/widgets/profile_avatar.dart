import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditOverlay;
  final bool isUploading;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.displayName,
    this.radius = 48,
    this.onTap,
    this.showEditOverlay = false,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(displayName);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primaryContainer,
            child: isUploading
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                    constraints: BoxConstraints(
                      maxWidth: radius,
                      maxHeight: radius,
                    ),
                  )
                : avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl!,
                          width: radius * 2,
                          height: radius * 2,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _InitialsView(
                            initials: initials,
                            radius: radius,
                          ),
                          errorWidget: (_, __, ___) => _InitialsView(
                            initials: initials,
                            radius: radius,
                          ),
                        ),
                      )
                    : _InitialsView(initials: initials, radius: radius),
          ),
          if (showEditOverlay && !isUploading)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: radius * 0.65,
                height: radius * 0.65,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: radius * 0.3,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

class _InitialsView extends StatelessWidget {
  final String initials;
  final double radius;

  const _InitialsView({required this.initials, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.45,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
