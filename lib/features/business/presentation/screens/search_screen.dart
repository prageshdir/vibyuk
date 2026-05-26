import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/discovery/discovery_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/active_filters_row.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_search_bar.dart';
import 'package:vibyuk/features/business/presentation/widgets/creator_list_tile.dart';
import 'package:vibyuk/features/business/presentation/widgets/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<DiscoveryBloc>().add(const LoadMoreResultsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<DiscoveryBloc, DiscoveryState>(
          builder: (context, state) => BusinessSearchBar(
            autofocus: true,
            initialValue: state is DiscoveryLoadedState ? state.query : null,
            hintText: 'Search creators, skills...',
            onChanged: (q) => context
                .read<DiscoveryBloc>()
                .add(SearchQueryChangedEvent(query: q)),
            onFilterTap: () => _showFilters(context, state),
            activeFilterCount: state is DiscoveryLoadedState
                ? state.filters.activeFilterCount
                : 0,
            onClear: () => context
                .read<DiscoveryBloc>()
                .add(const InitializeDiscoveryEvent()),
          ),
        ),
        titleSpacing: 0,
        leadingWidth: 56,
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) => switch (state) {
          DiscoveryInitialState(:final recentSearches) =>
            _RecentSearches(
              searches: recentSearches,
              onTap: (q) => context
                  .read<DiscoveryBloc>()
                  .add(ExecuteSearchEvent(
                    query: q,
                    filters: const SearchFiltersEntity.empty(),
                  )),
            ),
          DiscoveryLoadingState() =>
            const Center(child: AppLoader()),
          DiscoveryLoadedState(
            :final creators,
            :final filters,
            :final totalItems,
            :final hasMore,
            :final isLoadingMore
          ) =>
            Column(
              children: [
                if (filters.activeFilterCount > 0)
                  ActiveFiltersRow(
                    filters: filters,
                    onClearAll: () => context
                        .read<DiscoveryBloc>()
                        .add(const ClearFiltersEvent()),
                    onFilterRemoved: (f) => context
                        .read<DiscoveryBloc>()
                        .add(ApplyFiltersEvent(filters: f)),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '$totalItems results',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: creators.isEmpty
                      ? const BusinessEmptyState.noCreators()
                      : ListView.separated(
                          controller: _scrollController,
                          itemCount:
                              creators.length + (isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 76),
                          itemBuilder: (context, index) {
                            if (index == creators.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: AppLoader(size: 24)),
                              );
                            }
                            final creator = creators[index];
                            return CreatorListTile(
                              creator: creator,
                              onTap: () => context.push(
                                  '/discover/creators/${creator.id}'),
                              onSaveTap: () =>
                                  context.read<DiscoveryBloc>().add(
                                        ToggleSaveCreatorEvent(
                                          creatorId: creator.id,
                                          currentlySaved: creator.isSaved,
                                        ),
                                      ),
                            );
                          },
                        ),
                ),
              ],
            ),
          DiscoveryErrorState(:final failure) =>
            BusinessEmptyState(
              title: 'Search failed',
              description: failure.message,
              icon: Icons.error_outline_rounded,
              actionLabel: 'Try again',
              onAction: () => context
                  .read<DiscoveryBloc>()
                  .add(const InitializeDiscoveryEvent()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _showFilters(BuildContext context, DiscoveryState state) {
    final current = state is DiscoveryLoadedState
        ? state.filters
        : const SearchFiltersEntity.empty();
    FilterBottomSheet.show(
      context,
      initialFilters: current,
      onApply: (f) =>
          context.read<DiscoveryBloc>().add(ApplyFiltersEvent(filters: f)),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;

  const _RecentSearches({required this.searches, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_rounded, size: 48, color: AppColors.textDisabled),
              SizedBox(height: 12),
              Text(
                'Search for creators',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Recent searches',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        ...searches.map(
          (query) => ListTile(
            leading: const Icon(Icons.history_rounded,
                color: AppColors.textSecondary),
            title: Text(query),
            onTap: () => onTap(query),
            dense: true,
          ),
        ),
      ],
    );
  }
}
