part of 'discovery_bloc.dart';

sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();
}

class InitializeDiscoveryEvent extends DiscoveryEvent {
  const InitializeDiscoveryEvent();
  @override
  List<Object?> get props => [];
}

class SearchQueryChangedEvent extends DiscoveryEvent {
  const SearchQueryChangedEvent({required this.query});
  final String query;
  @override
  List<Object?> get props => [query];
}

class ExecuteSearchEvent extends DiscoveryEvent {
  const ExecuteSearchEvent({
    required this.query,
    required this.filters,
    this.page = 1,
  });
  final String query;
  final SearchFiltersEntity filters;
  final int page;
  @override
  List<Object?> get props => [query, filters, page];
}

class LoadMoreResultsEvent extends DiscoveryEvent {
  const LoadMoreResultsEvent();
  @override
  List<Object?> get props => [];
}

class ApplyFiltersEvent extends DiscoveryEvent {
  const ApplyFiltersEvent({required this.filters});
  final SearchFiltersEntity filters;
  @override
  List<Object?> get props => [filters];
}

class ClearFiltersEvent extends DiscoveryEvent {
  const ClearFiltersEvent();
  @override
  List<Object?> get props => [];
}

class ToggleSaveCreatorEvent extends DiscoveryEvent {
  const ToggleSaveCreatorEvent({
    required this.creatorId,
    required this.currentlySaved,
  });
  final String creatorId;
  final bool currentlySaved;
  @override
  List<Object?> get props => [creatorId, currentlySaved];
}

class LoadSavedCreatorsEvent extends DiscoveryEvent {
  const LoadSavedCreatorsEvent();
  @override
  List<Object?> get props => [];
}
