import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_destinations_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_featured_destinations_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class DestinationListEvent extends Equatable {
  const DestinationListEvent();
  @override
  List<Object?> get props => [];
}

final class DestinationListLoaded extends DestinationListEvent {
  const DestinationListLoaded({
    this.category,
    this.region,
    this.query,
    this.featuredOnly = false,
  });
  final String? category;
  final String? region;
  final String? query;
  final bool featuredOnly;
  @override
  List<Object?> get props => [category, region, query, featuredOnly];
}

final class DestinationListNextPage extends DestinationListEvent {
  const DestinationListNextPage();
}

final class DestinationListFiltered extends DestinationListEvent {
  const DestinationListFiltered({this.category, this.region});
  final String? category;
  final String? region;
  @override
  List<Object?> get props => [category, region];
}

final class DestinationListSearched extends DestinationListEvent {
  const DestinationListSearched(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class DestinationListRefreshed extends DestinationListEvent {
  const DestinationListRefreshed();
}

// ── State ─────────────────────────────────────────────────────────────────────

final class DestinationListState extends Equatable {
  const DestinationListState({
    this.status = DestinationListStatus.initial,
    this.destinations = const [],
    this.featuredDestinations = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedCategory,
    this.selectedRegion,
    this.searchQuery,
    this.errorMessage,
  });

  final DestinationListStatus status;
  final List<TourismDestinationEntity> destinations;
  final List<TourismDestinationEntity> featuredDestinations;
  final int currentPage;
  final bool hasMore;
  final String? selectedCategory;
  final String? selectedRegion;
  final String? searchQuery;
  final String? errorMessage;

  bool get isLoading => status == DestinationListStatus.loading;
  bool get isLoadingMore => status == DestinationListStatus.loadingMore;

  DestinationListState copyWith({
    DestinationListStatus? status,
    List<TourismDestinationEntity>? destinations,
    List<TourismDestinationEntity>? featuredDestinations,
    int? currentPage,
    bool? hasMore,
    String? selectedCategory,
    bool clearCategory = false,
    String? selectedRegion,
    bool clearRegion = false,
    String? searchQuery,
    bool clearSearch = false,
    String? errorMessage,
  }) =>
      DestinationListState(
        status: status ?? this.status,
        destinations: destinations ?? this.destinations,
        featuredDestinations:
            featuredDestinations ?? this.featuredDestinations,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        selectedCategory:
            clearCategory ? null : selectedCategory ?? this.selectedCategory,
        selectedRegion:
            clearRegion ? null : selectedRegion ?? this.selectedRegion,
        searchQuery: clearSearch ? null : searchQuery ?? this.searchQuery,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        destinations,
        featuredDestinations,
        currentPage,
        hasMore,
        selectedCategory,
        selectedRegion,
        searchQuery,
        errorMessage,
      ];
}

enum DestinationListStatus { initial, loading, loadingMore, loaded, error }

// ── BLoC ─────────────────────────────────────────────────────────────────────

class DestinationListBloc
    extends BaseBloc<DestinationListEvent, DestinationListState> {
  DestinationListBloc({
    required GetDestinationsUseCase getDestinations,
    required GetFeaturedDestinationsUseCase getFeaturedDestinations,
  })  : _getDestinations = getDestinations,
        _getFeaturedDestinations = getFeaturedDestinations,
        super(const DestinationListState()) {
    on<DestinationListLoaded>(_onLoaded);
    on<DestinationListNextPage>(_onNextPage);
    on<DestinationListFiltered>(_onFiltered);
    on<DestinationListSearched>(_onSearched);
    on<DestinationListRefreshed>(_onRefreshed);
  }

  final GetDestinationsUseCase _getDestinations;
  final GetFeaturedDestinationsUseCase _getFeaturedDestinations;

  Future<void> _onLoaded(
    DestinationListLoaded event,
    Emitter<DestinationListState> emit,
  ) async {
    emit(state.copyWith(
      status: DestinationListStatus.loading,
      selectedCategory: event.category,
      selectedRegion: event.region,
      searchQuery: event.query,
      clearSearch: event.query == null,
    ));

    final featuredResult = await _getFeaturedDestinations();
    final featuredDestinations = featuredResult.fold((_) => <TourismDestinationEntity>[], (d) => d);

    final result = await _getDestinations(GetDestinationsParams(
      page: 1,
      category: event.category,
      region: event.region,
      query: event.query,
      featuredOnly: event.featuredOnly,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: DestinationListStatus.error,
        errorMessage: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        status: DestinationListStatus.loaded,
        destinations: paginated.items,
        featuredDestinations: featuredDestinations,
        currentPage: 1,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onNextPage(
    DestinationListNextPage event,
    Emitter<DestinationListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(status: DestinationListStatus.loadingMore));
    final nextPage = state.currentPage + 1;

    final result = await _getDestinations(GetDestinationsParams(
      page: nextPage,
      category: state.selectedCategory,
      region: state.selectedRegion,
      query: state.searchQuery,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: DestinationListStatus.loaded,
        errorMessage: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        status: DestinationListStatus.loaded,
        destinations: [...state.destinations, ...paginated.items],
        currentPage: nextPage,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onFiltered(
    DestinationListFiltered event,
    Emitter<DestinationListState> emit,
  ) async {
    add(DestinationListLoaded(
      category: event.category,
      region: event.region,
      query: state.searchQuery,
    ));
  }

  Future<void> _onSearched(
    DestinationListSearched event,
    Emitter<DestinationListState> emit,
  ) async {
    add(DestinationListLoaded(
      category: state.selectedCategory,
      region: state.selectedRegion,
      query: event.query.isEmpty ? null : event.query,
    ));
  }

  Future<void> _onRefreshed(
    DestinationListRefreshed event,
    Emitter<DestinationListState> emit,
  ) async {
    add(DestinationListLoaded(
      category: state.selectedCategory,
      region: state.selectedRegion,
      query: state.searchQuery,
    ));
  }
}
