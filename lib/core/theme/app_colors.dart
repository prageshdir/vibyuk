import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand — Primary (Electric Violet)
  static const Color primary = Color(0xFF7B2FFF);
  static const Color primaryLight = Color(0xFF9B5FFF);
  static const Color primaryDark = Color(0xFF5A0FDF);
  static const Color primaryContainer = Color(0xFFEDE0FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // Brand — Secondary (Vibrant Coral)
  static const Color secondary = Color(0xFFFF5C6B);
  static const Color secondaryLight = Color(0xFFFF8C96);
  static const Color secondaryDark = Color(0xFFCC3345);
  static const Color secondaryContainer = Color(0xFFFFDADC);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF410009);

  // Brand — Tertiary (Neon Teal)
  static const Color tertiary = Color(0xFF00D9C0);
  static const Color tertiaryContainer = Color(0xFFB2FFF5);
  static const Color onTertiary = Color(0xFF002B27);
  static const Color onTertiaryContainer = Color(0xFF00201D);

  // Neutrals
  static const Color surface = Color(0xFFFFFBFF);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color background = Color(0xFFFFFBFF);
  static const Color outline = Color(0xFF79757F);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Dark mode surfaces
  static const Color surfaceDark = Color(0xFF141218);
  static const Color surfaceVariantDark = Color(0xFF49454F);
  static const Color backgroundDark = Color(0xFF141218);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);

  // Semantic
  static const Color success = Color(0xFF00C853);
  static const Color successContainer = Color(0xFFB9F6CA);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningContainer = Color(0xFFFFECB3);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  // Text
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textDisabled = Color(0xFF938F99);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Elevation overlays
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFE7E0EC);

  // Gradient stops
  static const List<Color> brandGradient = [primary, secondary];
  static const List<Color> creatorGradient = [Color(0xFF7B2FFF), Color(0xFF00D9C0)];

  AppColors._();
}
