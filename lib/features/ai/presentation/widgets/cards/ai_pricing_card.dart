import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';

class AiPricingCard extends StatelessWidget {
  final AiPricingSuggestion suggestion;
  final bool isActive;
  final VoidCallback? onTap;

  const AiPricingCard({
    super.key,
    required this.suggestion,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceColor = switch (suggestion.confidence) {
      PricingConfidence.veryHigh => AppColors.success,
      PricingConfidence.high => AppColors.tertiary,
      PricingConfidence.medium => AppColors.warning,
      PricingConfidence.low => AppColors.error,
    };

    final confidenceLabel = switch (suggestion.confidence) {
      PricingConfidence.veryHigh => 'Very High',
      PricingConfidence.high => 'High',
      PricingConfidence.medium => 'Medium',
      PricingConfidence.low => 'Low',
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isActive
                ? AppColors.primary.withOpacity(0.6)
                : AppColors.outline.withOpacity(0.2),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    _serviceTypeLabel(suggestion.serviceType),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          size: 12, color: confidenceColor),
                      const SizedBox(width: 4),
                      Text(
                        '$confidenceLabel Confidence',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: confidenceColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Price range display
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${suggestion.suggestedPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 6),
                  child: Text(
                    'suggested',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Range bar
            _PriceRangeBar(
              min: suggestion.minPrice,
              max: suggestion.maxPrice,
              suggested: suggestion.suggestedPrice,
              currency: suggestion.currency,
            ),

            const SizedBox(height: 12),

            // Market comparison
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.tertiary.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'re in the top ${(suggestion.marketComparison.percentileRank * 100).toInt()}th percentile of your market',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Key factors
            Text(
              'Key Pricing Factors',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            ...suggestion.factors.take(3).map(
                  (factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _FactorRow(factor: factor),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String _serviceTypeLabel(PricingServiceType type) {
    return switch (type) {
      PricingServiceType.photography => 'Photography',
      PricingServiceType.videography => 'Videography',
      PricingServiceType.musicPerformance => 'Music Performance',
      PricingServiceType.djSet => 'DJ Set',
      PricingServiceType.eventPlanning => 'Event Planning',
      PricingServiceType.speaking => 'Speaking Engagement',
      PricingServiceType.brandDesign => 'Brand Design',
      PricingServiceType.socialContent => 'Social Content',
    };
  }
}

class _PriceRangeBar extends StatelessWidget {
  final double min;
  final double max;
  final double suggested;
  final String currency;

  const _PriceRangeBar({
    required this.min,
    required this.max,
    required this.suggested,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final range = max - min;
    final position = range == 0 ? 0.5 : (suggested - min) / range;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withOpacity(0.4),
                    AppColors.success.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            Positioned(
              left: (MediaQuery.of(context).size.width - 64) * position - 6,
              top: -3,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${min.toStringAsFixed(0)} min',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            Text(
              '₹${max.toStringAsFixed(0)} max',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _FactorRow extends StatelessWidget {
  final AiPricingFactor factor;

  const _FactorRow({required this.factor});

  @override
  Widget build(BuildContext context) {
    final isPositive = factor.impact >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Row(
      children: [
        Icon(
          isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            factor.label,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        Text(
          '${isPositive ? '+' : ''}${(factor.impact * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
