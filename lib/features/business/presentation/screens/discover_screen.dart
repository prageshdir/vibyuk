import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/discovery/discovery_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/active_filters_row.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_search_bar.dart';
import 'package:vibyuk/features/business/presentation/widgets/creator_card.dart';
import 'package:vibyuk/features/business/presentation/widgets/filter_bottom_sheet.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(const InitializeDiscoveryEvent());
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
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _AppBar(state: state),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: BusinessSearchBar(
                    hintText: 'Search creators, skills...',
                    onChanged: (q) => context
                        .read<DiscoveryBloc>()
                        .add(SearchQueryChangedEvent(query: q)),
                    onFilterTap: () => _showFilters(context, state),
                    activeFilterCount: state is DiscoveryLoadedState
                        ? state.filters.activeFilterCount
                        : 0,
                  ),
                ),
              ),
              if (state is DiscoveryLoadedState &&
                  state.filters.activeFilterCount > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ActiveFiltersRow(
                      filters: state.filters,
                      onClearAll: () => context
                          .read<DiscoveryBloc>()
                          .add(const ClearFiltersEvent()),
                      onFilterRemoved: (f) => context
                          .read<DiscoveryBloc>()
                          .add(ApplyFiltersEvent(filters: f)),
                    ),
                  ),
                ),
              ..._buildBody(context, state),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, DiscoveryState state) {
    return switch (state) {
      DiscoveryInitialState(:final featuredCreators) => [
          if (featuredCreators.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Featured Creators',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _FeaturedCarousel(creators: featuredCreators),
            ),
          ],
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'Discover Creators',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      DiscoveryLoadingState() => [
          const SliverFillRemaining(
            child: Center(child: AppLoader()),
          ),
        ],
      DiscoveryLoadedState(:final creators, :final hasMore, :final isLoadingMore) => [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: creators.isEmpty
                ? const SliverToBoxAdapter(
                    child: BusinessEmptyState.noCreators(),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final creator = creators[index];
                        return CreatorCard(
                          creator: creator,
                          onTap: () => context.push(
                              '/discover/creators/${creator.id}'),
                          onSaveTap: () => context
                              .read<DiscoveryBloc>()
                              .add(ToggleSaveCreatorEvent(
                                creatorId: creator.id,
                                currentlySaved: creator.isSaved,
                              )),
                        );
                      },
                      childCount: creators.length,
                    ),
                  ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: AppLoader(size: 28)),
              ),
            ),
        ],
      DiscoveryErrorState(:final failure) => [
          SliverFillRemaining(
            child: BusinessEmptyState(
              title: 'Something went wrong',
              description: failure.message,
              icon: Icons.error_outline_rounded,
              actionLabel: 'Retry',
              onAction: () => context
                  .read<DiscoveryBloc>()
                  .add(const InitializeDiscoveryEvent()),
            ),
          ),
        ],
      _ => [const SliverToBoxAdapter(child: SizedBox.shrink())],
    };
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

class _AppBar extends StatelessWidget {
  final DiscoveryState state;
  const _AppBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: const Text(
        'Discover',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border_rounded),
          onPressed: () => context.push('/discover/saved'),
          tooltip: 'Saved creators',
        ),
      ],
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  final List<CreatorEntity> creators;
  const _FeaturedCarousel({required this.creators});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: creators.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final creator = creators[index];
          return SizedBox(
            width: 160,
            child: CreatorCard(
              creator: creator,
              onTap: () =>
                  context.push('/discover/creators/${creator.id}'),
              onSaveTap: () => context.read<DiscoveryBloc>().add(
                    ToggleSaveCreatorEvent(
                      creatorId: creator.id,
                      currentlySaved: creator.isSaved,
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }
}
