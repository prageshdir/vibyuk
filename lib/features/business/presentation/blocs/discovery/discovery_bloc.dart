import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/get_featured_creators_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/get_recent_searches_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/get_saved_creators_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/save_creator_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/save_recent_search_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/search_creators_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/unsave_creator_use_case.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

class DiscoveryBloc extends BaseBloc<DiscoveryEvent, DiscoveryState> {
  DiscoveryBloc({
    required SearchCreatorsUseCase searchCreators,
    required GetFeaturedCreatorsUseCase getFeaturedCreators,
    required GetRecentSearchesUseCase getRecentSearches,
    required SaveRecentSearchUseCase saveRecentSearch,
    required SaveCreatorUseCase saveCreator,
    required UnsaveCreatorUseCase unsaveCreator,
    required GetSavedCreatorsUseCase getSavedCreators,
  })  : _searchCreators = searchCreators,
        _getFeaturedCreators = getFeaturedCreators,
        _getRecentSearches = getRecentSearches,
        _saveRecentSearch = saveRecentSearch,
        _saveCreator = saveCreator,
        _unsaveCreator = unsaveCreator,
        _getSavedCreators = getSavedCreators,
        super(const DiscoveryInitialState()) {
    on<InitializeDiscoveryEvent>(_onInitialize);
    on<SearchQueryChangedEvent>(_onQueryChanged);
    on<ExecuteSearchEvent>(_onExecuteSearch);
    on<LoadMoreResultsEvent>(_onLoadMore);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFiltersEvent>(_onClearFilters);
    on<ToggleSaveCreatorEvent>(_onToggleSave);
    on<LoadSavedCreatorsEvent>(_onLoadSaved);
  }

  final SearchCreatorsUseCase _searchCreators;
  final GetFeaturedCreatorsUseCase _getFeaturedCreators;
  final GetRecentSearchesUseCase _getRecentSearches;
  final SaveRecentSearchUseCase _saveRecentSearch;
  final SaveCreatorUseCase _saveCreator;
  final UnsaveCreatorUseCase _unsaveCreator;
  final GetSavedCreatorsUseCase _getSavedCreators;

  Timer? _debounceTimer;
  SearchFiltersEntity _currentFilters = const SearchFiltersEntity.empty();
  String _currentQuery = '';

  Future<void> _onInitialize(
      InitializeDiscoveryEvent event, Emitter<DiscoveryState> emit) async {
    final featuredResult = await _getFeaturedCreators();
    final recentResult = await _getRecentSearches();
    emit(DiscoveryInitialState(
      featuredCreators: featuredResult.fold((_) => [], (c) => c),
      recentSearches: recentResult.fold((_) => [], (s) => s),
    ));
  }

  void _onQueryChanged(
      SearchQueryChangedEvent event, Emitter<DiscoveryState> emit) {
    _currentQuery = event.query;
    _debounceTimer?.cancel();
    if (event.query.isEmpty) {
      add(const InitializeDiscoveryEvent());
      return;
    }
    emit(const DiscoveryLoadingState());
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(ExecuteSearchEvent(query: event.query, filters: _currentFilters));
    });
  }

  Future<void> _onExecuteSearch(
      ExecuteSearchEvent event, Emitter<DiscoveryState> emit) async {
    if (event.page == 1) emit(const DiscoveryLoadingState());
    if (event.query.isNotEmpty) {
      await _saveRecentSearch(SaveRecentSearchParams(query: event.query));
    }
    final result = await _searchCreators(SearchCreatorsParams(
      query: event.query,
      filters: event.filters,
      page: event.page,
    ));
    result.fold(
      (failure) => emit(DiscoveryErrorState(failure: failure)),
      (page) {
        final existing = state is DiscoveryLoadedState && event.page > 1
            ? (state as DiscoveryLoadedState).creators
            : <CreatorEntity>[];
        emit(DiscoveryLoadedState(
          creators: [...existing, ...page.items],
          query: event.query,
          filters: event.filters,
          currentPage: page.currentPage,
          hasMore: page.hasNextPage,
          totalItems: page.totalItems,
        ));
      },
    );
  }

  Future<void> _onLoadMore(
      LoadMoreResultsEvent event, Emitter<DiscoveryState> emit) async {
    if (state is! DiscoveryLoadedState) return;
    final loaded = state as DiscoveryLoadedState;
    if (!loaded.hasMore || loaded.isLoadingMore) return;

    emit(loaded.copyWith(isLoadingMore: true));
    final result = await _searchCreators(SearchCreatorsParams(
      query: loaded.query,
      filters: loaded.filters,
      page: loaded.currentPage + 1,
    ));
    result.fold(
      (failure) => emit(DiscoveryErrorState(failure: failure)),
      (page) => emit(loaded.copyWith(
        creators: [...loaded.creators, ...page.items],
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        isLoadingMore: false,
        totalItems: page.totalItems,
      )),
    );
  }

  void _onApplyFilters(ApplyFiltersEvent event, Emitter<DiscoveryState> emit) {
    _currentFilters = event.filters;
    if (_currentQuery.isNotEmpty) {
      add(ExecuteSearchEvent(query: _currentQuery, filters: event.filters));
    }
  }

  void _onClearFilters(ClearFiltersEvent event, Emitter<DiscoveryState> emit) {
    _currentFilters = const SearchFiltersEntity.empty();
    if (_currentQuery.isNotEmpty) {
      add(ExecuteSearchEvent(
          query: _currentQuery, filters: const SearchFiltersEntity.empty()));
    }
  }

  Future<void> _onToggleSave(
      ToggleSaveCreatorEvent event, Emitter<DiscoveryState> emit) async {
    if (event.currentlySaved) {
      await _unsaveCreator(UnsaveCreatorParams(creatorId: event.creatorId));
    } else {
      await _saveCreator(SaveCreatorParams(creatorId: event.creatorId));
    }
    if (state is DiscoveryLoadedState) {
      final loaded = state as DiscoveryLoadedState;
      final updated = loaded.creators.map((c) {
        if (c.id == event.creatorId) return c.copyWith(isSaved: !event.currentlySaved);
        return c;
      }).toList();
      emit(loaded.copyWith(creators: updated));
    }
  }

  Future<void> _onLoadSaved(
      LoadSavedCreatorsEvent event, Emitter<DiscoveryState> emit) async {
    emit(const DiscoveryLoadingState());
    final result = await _getSavedCreators(const GetSavedCreatorsParams());
    result.fold(
      (failure) => emit(DiscoveryErrorState(failure: failure)),
      (page) => emit(SavedCreatorsLoadedState(
        creators: page.items,
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
      )),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
