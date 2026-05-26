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
      DiscoveryInitialState(:final featuredCreators, :final trendingCreators) => [
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
          if (trendingCreators.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded,
                        size: 18, color: Colors.orange),
                    SizedBox(width: 6),
                    Text(
                      'Trending Now',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _TrendingCreatorsList(creators: trendingCreators),
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
      DiscoveryLoadedState(
          :final creators,
          :final hasMore,
          :final isLoadingMore,
          :final selectedForComparison,
        ) => [
          if (selectedForComparison.isNotEmpty)
            SliverToBoxAdapter(
              child: _CompareBanner(
                count: selectedForComparison.length,
                onCompare: () => context.push(
                  '/discover/compare',
                  extra: selectedForComparison,
                ),
                onClear: () => context
                    .read<DiscoveryBloc>()
                    .add(const ClearComparisonEvent()),
              ),
            ),
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
                        final isSelected = selectedForComparison
                            .contains(creator.id);
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
                          onCompareTap: (selectedForComparison.length < 3 ||
                                  isSelected)
                              ? () => context
                                  .read<DiscoveryBloc>()
                                  .add(ToggleCompareCreatorEvent(
                                      creatorId: creator.id))
                              : null,
                          isSelectedForComparison: isSelected,
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

class _CompareBanner extends StatelessWidget {
  const _CompareBanner({
    required this.count,
    required this.onCompare,
    required this.onClear,
  });
  final int count;
  final VoidCallback onCompare;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.compare_arrows_rounded,
              size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count creator${count == 1 ? '' : 's'} selected'
              '${count < 2 ? ' — add ${2 - count} more' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (count >= 2)
            TextButton(
              onPressed: onCompare,
              style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10)),
              child: const Text('Compare'),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onClear,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _TrendingCreatorsList extends StatelessWidget {
  const _TrendingCreatorsList({required this.creators});
  final List<CreatorEntity> creators;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: creators.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final creator = creators[index];
          return GestureDetector(
            onTap: () =>
                context.push('/discover/creators/${creator.id}'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: creator.avatarUrl != null
                      ? NetworkImage(creator.avatarUrl!)
                      : null,
                  child: creator.avatarUrl == null
                      ? Text(creator.initials,
                          style: const TextStyle(fontWeight: FontWeight.w700))
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(creator.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    if (creator.categories.isNotEmpty)
                      Text(creator.categories.first,
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    Text('${_formatK(creator.followersCount)} followers',
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatK(int n) => n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}M'
      : n >= 1000
          ? '${(n / 1000).toStringAsFixed(0)}K'
          : '$n';
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
