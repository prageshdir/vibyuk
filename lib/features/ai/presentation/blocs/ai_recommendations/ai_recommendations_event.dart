import 'package:equatable/equatable.dart';

abstract class AiRecommendationsEvent extends Equatable {
  const AiRecommendationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecommendations extends AiRecommendationsEvent {
  final String eventType;
  final double budget;
  final String location;
  final Map<String, dynamic>? filters;

  const LoadRecommendations({
    required this.eventType,
    required this.budget,
    required this.location,
    this.filters,
  });

  @override
  List<Object?> get props => [eventType, budget, location, filters];
}

class RefreshRecommendations extends AiRecommendationsEvent {
  const RefreshRecommendations();
}

class ToggleBookmarkRecommendation extends AiRecommendationsEvent {
  final String recommendationId;

  const ToggleBookmarkRecommendation({required this.recommendationId});

  @override
  List<Object?> get props => [recommendationId];
}

class FilterRecommendations extends AiRecommendationsEvent {
  final String? category;
  final double? maxBudget;
  final double? minRating;

  const FilterRecommendations({
    this.category,
    this.maxBudget,
    this.minRating,
  });

  @override
  List<Object?> get props => [category, maxBudget, minRating];
}
