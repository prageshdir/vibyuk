import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_recommendation.dart';

enum AiRecommendationsStatus { initial, loading, success, failure, refreshing }

class AiRecommendationsState extends Equatable {
  final AiRecommendationsStatus status;
  final List<AiRecommendation> recommendations;
  final List<AiRecommendation> filteredRecommendations;
  final Failure? failure;
  final String? activeCategory;
  final double? maxBudgetFilter;
  final double? minRatingFilter;
  final String? lastEventType;
  final String? lastLocation;

  const AiRecommendationsState({
    this.status = AiRecommendationsStatus.initial,
    this.recommendations = const [],
    this.filteredRecommendations = const [],
    this.failure,
    this.activeCategory,
    this.maxBudgetFilter,
    this.minRatingFilter,
    this.lastEventType,
    this.lastLocation,
  });

  bool get isLoading => status == AiRecommendationsStatus.loading;
  bool get isRefreshing => status == AiRecommendationsStatus.refreshing;
  bool get hasData => recommendations.isNotEmpty;
  bool get hasError => status == AiRecommendationsStatus.failure;

  AiRecommendationsState copyWith({
    AiRecommendationsStatus? status,
    List<AiRecommendation>? recommendations,
    List<AiRecommendation>? filteredRecommendations,
    Failure? failure,
    String? activeCategory,
    double? maxBudgetFilter,
    double? minRatingFilter,
    String? lastEventType,
    String? lastLocation,
  }) {
    return AiRecommendationsState(
      status: status ?? this.status,
      recommendations: recommendations ?? this.recommendations,
      filteredRecommendations:
          filteredRecommendations ?? this.filteredRecommendations,
      failure: failure ?? this.failure,
      activeCategory: activeCategory ?? this.activeCategory,
      maxBudgetFilter: maxBudgetFilter ?? this.maxBudgetFilter,
      minRatingFilter: minRatingFilter ?? this.minRatingFilter,
      lastEventType: lastEventType ?? this.lastEventType,
      lastLocation: lastLocation ?? this.lastLocation,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recommendations,
        filteredRecommendations,
        failure,
        activeCategory,
        maxBudgetFilter,
        minRatingFilter,
        lastEventType,
        lastLocation,
      ];
}
