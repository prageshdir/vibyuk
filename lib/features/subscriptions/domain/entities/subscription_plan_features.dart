import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';

enum SubscriptionFeature {
  unlimitedPortfolio,
  priorityDiscovery,
  fullAnalytics,
  aiRecommendations,
  aiCampaignPlanner,
  customPricingSuggestions,
  featuredPlacement,
  advancedChat,
  verifiedBadge,
}

class SubscriptionPlanFeatures {
  const SubscriptionPlanFeatures._({
    required this.maxPortfolioItems,
    required this.features,
  });

  final int maxPortfolioItems; // -1 = unlimited
  final Set<SubscriptionFeature> features;

  static SubscriptionPlanFeatures forPlan(SubscriptionPlan plan) =>
      switch (plan) {
        SubscriptionPlan.free => const SubscriptionPlanFeatures._(
            maxPortfolioItems: 5,
            features: {},
          ),
        SubscriptionPlan.pro => const SubscriptionPlanFeatures._(
            maxPortfolioItems: -1,
            features: {
              SubscriptionFeature.unlimitedPortfolio,
              SubscriptionFeature.priorityDiscovery,
              SubscriptionFeature.fullAnalytics,
              SubscriptionFeature.aiRecommendations,
              SubscriptionFeature.advancedChat,
              SubscriptionFeature.verifiedBadge,
            },
          ),
        SubscriptionPlan.elite => const SubscriptionPlanFeatures._(
            maxPortfolioItems: -1,
            features: {
              SubscriptionFeature.unlimitedPortfolio,
              SubscriptionFeature.priorityDiscovery,
              SubscriptionFeature.fullAnalytics,
              SubscriptionFeature.aiRecommendations,
              SubscriptionFeature.advancedChat,
              SubscriptionFeature.verifiedBadge,
              SubscriptionFeature.aiCampaignPlanner,
              SubscriptionFeature.customPricingSuggestions,
              SubscriptionFeature.featuredPlacement,
            },
          ),
      };

  bool hasAccess(SubscriptionFeature feature) => features.contains(feature);
  bool get hasUnlimitedPortfolio => maxPortfolioItems == -1;

  // Human-readable feature list for the upgrade screen
  static List<_PlanFeatureRow> displayFeatures(SubscriptionPlan plan) =>
      switch (plan) {
        SubscriptionPlan.free => const [
            _PlanFeatureRow('5 portfolio items'),
            _PlanFeatureRow('Basic discovery listing'),
            _PlanFeatureRow('Standard analytics (30 days)'),
            _PlanFeatureRow('Community support'),
          ],
        SubscriptionPlan.pro => const [
            _PlanFeatureRow('Unlimited portfolio items'),
            _PlanFeatureRow('Priority discovery placement'),
            _PlanFeatureRow('Full analytics dashboard'),
            _PlanFeatureRow('AI creator recommendations'),
            _PlanFeatureRow('Advanced chat features'),
            _PlanFeatureRow('Verified profile badge'),
          ],
        SubscriptionPlan.elite => const [
            _PlanFeatureRow('Everything in Pro'),
            _PlanFeatureRow('AI campaign planner'),
            _PlanFeatureRow('Custom pricing suggestions'),
            _PlanFeatureRow('Featured search placement'),
            _PlanFeatureRow('Dedicated account support'),
          ],
      };
}

class _PlanFeatureRow {
  const _PlanFeatureRow(this.label);
  final String label;
}
