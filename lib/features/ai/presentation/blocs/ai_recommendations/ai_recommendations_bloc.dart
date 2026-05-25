import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_recommendation.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_creator_recommendations_usecase.dart';
import 'ai_recommendations_event.dart';
import 'ai_recommendations_state.dart';

class AiRecommendationsBloc
    extends BaseBloc<AiRecommendationsEvent, AiRecommendationsState> {
  final GetCreatorRecommendationsUseCase _getRecommendations;

  AiRecommendationsBloc({
    required GetCreatorRecommendationsUseCase getRecommendations,
  })  : _getRecommendations = getRecommendations,
        super(const AiRecommendationsState()) {
    on<LoadRecommendations>(_onLoad);
    on<RefreshRecommendations>(_onRefresh);
    on<ToggleBookmarkRecommendation>(_onToggleBookmark);
    on<FilterRecommendations>(_onFilter);
  }

  Future<void> _onLoad(
    LoadRecommendations event,
    Emitter<AiRecommendationsState> emit,
  ) async {
    emit(state.copyWith(status: AiRecommendationsStatus.loading));

    final result = await _getRecommendations(
      RecommendationParams(
        eventType: event.eventType,
        budget: event.budget,
        location: event.location,
        filters: event.filters,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AiRecommendationsStatus.failure,
          failure: failure,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: AiRecommendationsStatus.success,
          recommendations: data,
          filteredRecommendations: data,
          lastEventType: event.eventType,
          lastLocation: event.location,
          failure: null,
        ),
      ),
    );
  }

  Future<void> _onRefresh(
    RefreshRecommendations event,
    Emitter<AiRecommendationsState> emit,
  ) async {
    if (state.lastEventType == null) return;
    emit(state.copyWith(status: AiRecommendationsStatus.refreshing));

    final result = await _getRecommendations(
      RecommendationParams(
        eventType: state.lastEventType!,
        budget: state.maxBudgetFilter ?? 5000,
        location: state.lastLocation ?? '',
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AiRecommendationsStatus.failure,
          failure: failure,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: AiRecommendationsStatus.success,
          recommendations: data,
          filteredRecommendations: _applyFilters(data),
          failure: null,
        ),
      ),
    );
  }

  void _onToggleBookmark(
    ToggleBookmarkRecommendation event,
    Emitter<AiRecommendationsState> emit,
  ) {
    final updated = state.recommendations.map((r) {
      if (r.id == event.recommendationId) {
        return r.copyWith(isBookmarked: !r.isBookmarked);
      }
      return r;
    }).toList();

    emit(state.copyWith(
      recommendations: updated,
      filteredRecommendations: _applyFilters(updated),
    ));
  }

  void _onFilter(
    FilterRecommendations event,
    Emitter<AiRecommendationsState> emit,
  ) {
    final newState = state.copyWith(
      activeCategory: event.category,
      maxBudgetFilter: event.maxBudget,
      minRatingFilter: event.minRating,
    );

    final filtered = _applyFiltersWithParams(
      state.recommendations,
      category: event.category,
      maxBudget: event.maxBudget,
      minRating: event.minRating,
    );

    emit(newState.copyWith(filteredRecommendations: filtered));
  }

  List<AiRecommendation> _applyFilters(List<AiRecommendation> data) {
    return _applyFiltersWithParams(
      data,
      category: state.activeCategory,
      maxBudget: state.maxBudgetFilter,
      minRating: state.minRatingFilter,
    );
  }

  List<AiRecommendation> _applyFiltersWithParams(
    List<AiRecommendation> data, {
    String? category,
    double? maxBudget,
    double? minRating,
  }) {
    return data.where((r) {
      if (category != null && r.category.name != category) return false;
      if (maxBudget != null && r.estimatedBudget > maxBudget) return false;
      if (minRating != null && r.rating < minRating) return false;
      return true;
    }).toList();
  }
}
