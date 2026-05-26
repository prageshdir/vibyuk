import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D2D2D) : AppColors.shimmerBase,
      highlightColor: isDark ? const Color(0xFF3D3D3D) : AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 56, height: 56, borderRadius: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                SkeletonBox(width: 160, height: 12),
                const SizedBox(height: 8),
                SkeletonBox(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) =>
      SkeletonBox(width: size, height: size, borderRadius: size / 2);
}

/// Admin user / dispute / report card skeleton
class SkeletonAdminCard extends StatelessWidget {
  const SkeletonAdminCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: double.infinity, height: 14),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 120, height: 11),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SkeletonBox(width: 60, height: 22, borderRadius: 20),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 11),
          const SizedBox(height: 6),
          SkeletonBox(width: 200, height: 11),
          const SizedBox(height: 12),
          Row(
            children: [
              SkeletonBox(width: 60, height: 20, borderRadius: 6),
              const SizedBox(width: 8),
              SkeletonBox(width: 80, height: 20, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

/// AI feature card skeleton
class SkeletonAiCard extends StatelessWidget {
  const SkeletonAiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7B2FFF).withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 48, height: 48, borderRadius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140, height: 14),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 80, height: 11),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 11),
          const SizedBox(height: 6),
          SkeletonBox(width: 220, height: 11),
          const SizedBox(height: 16),
          Row(
            children: [
              SkeletonBox(width: 70, height: 32, borderRadius: 10),
              const SizedBox(width: 8),
              SkeletonBox(width: 90, height: 32, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat / KPI card skeleton
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 36, height: 36, borderRadius: 10),
              SkeletonBox(width: 50, height: 20, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonBox(width: 80, height: 26),
          const SizedBox(height: 4),
          SkeletonBox(width: 110, height: 12),
        ],
      ),
    );
  }
}

/// Chart area skeleton
class SkeletonChart extends StatelessWidget {
  const SkeletonChart({super.key, this.height = 160});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 120, height: 14),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              7,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 20.0 + (i % 3) * 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              7,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SkeletonBox(width: double.infinity, height: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.itemBuilder,
  });

  final int itemCount;
  final Widget Function()? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (_, __) => itemBuilder?.call() ?? const SkeletonCard(),
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({
    super.key,
    this.itemCount = 4,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.4,
  });

  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      children: List.generate(itemCount, (_) => const SkeletonStatCard()),
    );
  }
}
