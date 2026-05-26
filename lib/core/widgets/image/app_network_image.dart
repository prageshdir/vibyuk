import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

/// Production-grade cached network image with:
/// - Shimmer skeleton while loading
/// - Graceful error fallback with initials/icon
/// - Memory + disk caching via CachedNetworkImage
/// - RepaintBoundary to isolate repaints
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeInDuration = const Duration(milliseconds: 250),
    this.fallbackIcon = Icons.image_rounded,
    this.fallbackInitials,
    this.fallbackColor,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  /// Resize image in memory to save RAM — set to rendered pixel dimensions.
  final int? memCacheWidth;
  final int? memCacheHeight;

  final Duration fadeInDuration;
  final IconData fallbackIcon;
  final String? fallbackInitials;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = url;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: effectiveUrl == null || effectiveUrl.isEmpty
              ? _buildFallback(context)
              : CachedNetworkImage(
                  imageUrl: effectiveUrl,
                  fit: fit,
                  width: width,
                  height: height,
                  memCacheWidth: memCacheWidth,
                  memCacheHeight: memCacheHeight,
                  fadeInDuration: fadeInDuration,
                  placeholder: (_, __) =>
                      placeholder ?? _buildShimmer(context),
                  errorWidget: (_, __, ___) =>
                      errorWidget ?? _buildFallback(context),
                ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D2D2D) : AppColors.shimmerBase,
      highlightColor:
          isDark ? const Color(0xFF3D3D3D) : AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        color: isDark ? const Color(0xFF2D2D2D) : AppColors.shimmerBase,
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final color = fallbackColor ?? AppColors.primary;

    if (fallbackInitials != null && fallbackInitials!.isNotEmpty) {
      return Container(
        width: width,
        height: height,
        color: color.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: Text(
          fallbackInitials![0].toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: (height ?? 40) * 0.4,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        size: (height ?? 40) * 0.4,
      ),
    );
  }
}

/// Circular avatar variant — common in user/creator cards.
class AppAvatarImage extends StatelessWidget {
  const AppAvatarImage({
    super.key,
    required this.url,
    required this.radius,
    this.initials,
    this.color,
    this.borderWidth = 0,
    this.borderColor,
  });

  final String? url;
  final double radius;
  final String? initials;
  final Color? color;
  final double borderWidth;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final avatarWidget = AppNetworkImage(
      url: url,
      width: radius * 2,
      height: radius * 2,
      borderRadius: radius,
      fit: BoxFit.cover,
      memCacheWidth: (radius * 2 * MediaQuery.of(context).devicePixelRatio).round(),
      memCacheHeight: (radius * 2 * MediaQuery.of(context).devicePixelRatio).round(),
      fallbackInitials: initials,
      fallbackColor: color ?? AppColors.primary,
    );

    if (borderWidth <= 0) return avatarWidget;

    return Container(
      width: radius * 2 + borderWidth * 2,
      height: radius * 2 + borderWidth * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? AppColors.primary,
          width: borderWidth,
        ),
      ),
      child: ClipOval(child: avatarWidget),
    );
  }
}
