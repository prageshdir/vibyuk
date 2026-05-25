part of 'discovery_bloc.dart';

sealed class DiscoveryState extends Equatable {
  const DiscoveryState();
}

class DiscoveryInitialState extends DiscoveryState {
  const DiscoveryInitialState({
    this.featuredCreators = const [],
    this.recentSearches = const [],
  });
  final List<CreatorEntity> featuredCreators;
  final List<String> recentSearches;
  @override
  List<Object?> get props => [featuredCreators, recentSearches];
}

class DiscoveryLoadingState extends DiscoveryState {
  const DiscoveryLoadingState();
  @override
  List<Object?> get props => [];
}

class DiscoveryLoadedState extends DiscoveryState {
  const DiscoveryLoadedState({
    required this.creators,
    required this.query,
    required this.filters,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.totalItems = 0,
  });

  final List<CreatorEntity> creators;
  final String query;
  final SearchFiltersEntity filters;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final int totalItems;

  DiscoveryLoadedState copyWith({
    List<CreatorEntity>? creators,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    int? totalItems,
  }) =>
      DiscoveryLoadedState(
        creators: creators ?? this.creators,
        query: query,
        filters: filters,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        totalItems: totalItems ?? this.totalItems,
      );

  @override
  List<Object?> get props => [
        creators, query, filters, currentPage, hasMore, isLoadingMore, totalItems
      ];
}

class SavedCreatorsLoadedState extends DiscoveryState {
  const SavedCreatorsLoadedState({
    required this.creators,
    required this.hasMore,
    required this.currentPage,
  });
  final List<CreatorEntity> creators;
  final bool hasMore;
  final int currentPage;
  @override
  List<Object?> get props => [creators, hasMore, currentPage];
}

class DiscoveryErrorState extends DiscoveryState {
  const DiscoveryErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
