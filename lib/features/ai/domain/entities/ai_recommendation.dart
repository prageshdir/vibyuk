import 'package:equatable/equatable.dart';

enum RecommendationCategory {
  photography,
  videography,
  music,
  eventPlanning,
  design,
  social,
  catering,
  speaking,
}

class AiRecommendation extends Equatable {
  final String id;
  final String creatorId;
  final String creatorName;
  final String? avatarUrl;
  final RecommendationCategory category;
  final double matchScore;
  final List<String> matchReasons;
  final List<String> tags;
  final double estimatedBudget;
  final String currency;
  final List<String> portfolioHighlights;
  final double rating;
  final int totalBookings;
  final bool isBookmarked;
  final DateTime generatedAt;

  const AiRecommendation({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    this.avatarUrl,
    required this.category,
    required this.matchScore,
    required this.matchReasons,
    required this.tags,
    required this.estimatedBudget,
    this.currency = 'GBP',
    required this.portfolioHighlights,
    required this.rating,
    required this.totalBookings,
    this.isBookmarked = false,
    required this.generatedAt,
  });

  AiRecommendation copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? avatarUrl,
    RecommendationCategory? category,
    double? matchScore,
    List<String>? matchReasons,
    List<String>? tags,
    double? estimatedBudget,
    String? currency,
    List<String>? portfolioHighlights,
    double? rating,
    int? totalBookings,
    bool? isBookmarked,
    DateTime? generatedAt,
  }) {
    return AiRecommendation(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      category: category ?? this.category,
      matchScore: matchScore ?? this.matchScore,
      matchReasons: matchReasons ?? this.matchReasons,
      tags: tags ?? this.tags,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      currency: currency ?? this.currency,
      portfolioHighlights: portfolioHighlights ?? this.portfolioHighlights,
      rating: rating ?? this.rating,
      totalBookings: totalBookings ?? this.totalBookings,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorId,
        creatorName,
        avatarUrl,
        category,
        matchScore,
        matchReasons,
        tags,
        estimatedBudget,
        currency,
        portfolioHighlights,
        rating,
        totalBookings,
        isBookmarked,
        generatedAt,
      ];
}
