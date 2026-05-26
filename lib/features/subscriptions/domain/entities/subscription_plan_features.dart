import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';

enum SubscriptionFeature {
  unlimitedPortfolio,
  priorityPlacement,
  featuredBadge,
  analytics,
  aiPricingRecs,
  earlyCampaignAccess,
  verifiedBadge,
  priorityDiscovery,
  fullAnalytics,
  aiRecommendations,
  aiCampaignPlanner,
  customPricingSuggestions,
  featuredPlacement,
  advancedChat,
}

class SubscriptionPlanFeatures {
  const SubscriptionPlanFeatures._({
    required this.maxPortfolioItems,
    required this.features,
  });

  final int maxPortfolioItems;
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

class BusinessPlanFeatures {
  const BusinessPlanFeatures._({
    required this.maxCampaigns,
    required this.maxTeamMembers,
    required this.hasAIRecommendations,
    required this.hasFeaturedSearch,
    required this.hasWhiteLabel,
    required this.hasAPIAccess,
    required this.hasSLA,
    required this.hasAccountManager,
    required this.commissionRate,
  });

  final int maxCampaigns;
  final int maxTeamMembers;
  final bool hasAIRecommendations;
  final bool hasFeaturedSearch;
  final bool hasWhiteLabel;
  final bool hasAPIAccess;
  final bool hasSLA;
  final bool hasAccountManager;
  final double commissionRate;

  static BusinessPlanFeatures forPlan(BusinessPlan plan) {
    return switch (plan) {
      BusinessPlan.free => const BusinessPlanFeatures._(
          maxCampaigns: 2,
          maxTeamMembers: 0,
          hasAIRecommendations: false,
          hasFeaturedSearch: false,
          hasWhiteLabel: false,
          hasAPIAccess: false,
          hasSLA: false,
          hasAccountManager: false,
          commissionRate: 0.18,
        ),
      BusinessPlan.starter => const BusinessPlanFeatures._(
          maxCampaigns: 10,
          maxTeamMembers: 1,
          hasAIRecommendations: false,
          hasFeaturedSearch: true,
          hasWhiteLabel: false,
          hasAPIAccess: false,
          hasSLA: false,
          hasAccountManager: false,
          commissionRate: 0.15,
        ),
      BusinessPlan.professional => const BusinessPlanFeatures._(
          maxCampaigns: 999,
          maxTeamMembers: 5,
          hasAIRecommendations: true,
          hasFeaturedSearch: true,
          hasWhiteLabel: false,
          hasAPIAccess: false,
          hasSLA: false,
          hasAccountManager: false,
          commissionRate: 0.12,
        ),
      BusinessPlan.enterprise => const BusinessPlanFeatures._(
          maxCampaigns: 999,
          maxTeamMembers: 999,
          hasAIRecommendations: true,
          hasFeaturedSearch: true,
          hasWhiteLabel: true,
          hasAPIAccess: true,
          hasSLA: true,
          hasAccountManager: true,
          commissionRate: 0.10,
        ),
    };
  }

  List<String> get displayFeatureList {
    final features = <String>[];
    if (maxCampaigns == 999) {
      features.add('Unlimited campaigns');
    } else {
      features.add('$maxCampaigns campaigns/month');
    }
    if (maxTeamMembers == 999) {
      features.add('Unlimited team members');
    } else if (maxTeamMembers == 0) {
      features.add('Single user only');
    } else {
      features.add('$maxTeamMembers team member${maxTeamMembers > 1 ? 's' : ''}');
    }
    features.add('${(commissionRate * 100).toStringAsFixed(0)}% platform commission');
    if (hasFeaturedSearch) features.add('Featured in search results');
    if (hasAIRecommendations) features.add('AI creator recommendations');
    if (hasWhiteLabel) features.add('White-label reports');
    if (hasAPIAccess) features.add('API access');
    if (hasSLA) features.add('99.9% uptime SLA');
    if (hasAccountManager) features.add('Dedicated account manager');
    return features;
  }
}
