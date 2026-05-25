import 'package:vibyuk/features/ai/domain/entities/ai_recommendation.dart';

class AiRecommendationModel extends AiRecommendation {
  const AiRecommendationModel({
    required super.id,
    required super.creatorId,
    required super.creatorName,
    super.avatarUrl,
    required super.category,
    required super.matchScore,
    required super.matchReasons,
    required super.tags,
    required super.estimatedBudget,
    super.currency,
    required super.portfolioHighlights,
    required super.rating,
    required super.totalBookings,
    super.isBookmarked,
    required super.generatedAt,
  });

  factory AiRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiRecommendationModel(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      creatorName: json['creator_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      category: RecommendationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => RecommendationCategory.photography,
      ),
      matchScore: (json['match_score'] as num).toDouble(),
      matchReasons: List<String>.from(json['match_reasons'] as List),
      tags: List<String>.from(json['tags'] as List),
      estimatedBudget: (json['estimated_budget'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'GBP',
      portfolioHighlights:
          List<String>.from(json['portfolio_highlights'] as List),
      rating: (json['rating'] as num).toDouble(),
      totalBookings: json['total_bookings'] as int,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'avatar_url': avatarUrl,
      'category': category.name,
      'match_score': matchScore,
      'match_reasons': matchReasons,
      'tags': tags,
      'estimated_budget': estimatedBudget,
      'currency': currency,
      'portfolio_highlights': portfolioHighlights,
      'rating': rating,
      'total_bookings': totalBookings,
      'is_bookmarked': isBookmarked,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
