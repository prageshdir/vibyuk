import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/destination_list/destination_list_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/destination_card.dart';

class DestinationListScreen extends StatefulWidget {
  const DestinationListScreen({super.key});

  @override
  State<DestinationListScreen> createState() => _DestinationListScreenState();
}

class _DestinationListScreenState extends State<DestinationListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedCategory;

  static const _categories = [
    'beach',
    'mountain',
    'city',
    'cultural',
    'adventure',
    'wildlife',
    'luxury',
    'island',
  ];

  @override
  void initState() {
    super.initState();
    context.read<DestinationListBloc>().add(const DestinationListLoaded());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<DestinationListBloc>()
          .add(const DestinationListNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          SliverToBoxAdapter(child: _buildCategoryChips()),
          _buildFeaturedSection(),
          _buildDestinationGrid(),
          _buildLoadMoreIndicator(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Explore Destinations',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2B5EFF), Color(0xFF7B2FFF)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: () => context.push(RouteNames.tourismAnalyticsDashboard),
          tooltip: 'Analytics',
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search destinations, regions…',
        leading: const Icon(Icons.search),
        trailing: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context
                    .read<DestinationListBloc>()
                    .add(const DestinationListSearched(''));
              },
            ),
        ],
        onChanged: (q) {
          context
              .read<DestinationListBloc>()
              .add(DestinationListSearched(q));
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (_) {
                setState(() => _selectedCategory = null);
                context
                    .read<DestinationListBloc>()
                    .add(const DestinationListFiltered());
              },
              selectedColor: AppColors.primaryContainer,
            );
          }
          final cat = _categories[index - 1];
          return FilterChip(
            label: Text(_capitalize(cat)),
            selected: _selectedCategory == cat,
            onSelected: (_) {
              setState(() =>
                  _selectedCategory = _selectedCategory == cat ? null : cat);
              context.read<DestinationListBloc>().add(
                    DestinationListFiltered(
                      category: _selectedCategory,
                    ),
                  );
            },
            selectedColor: AppColors.primaryContainer,
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return BlocBuilder<DestinationListBloc, DestinationListState>(
      buildWhen: (p, c) => p.featuredDestinations != c.featuredDestinations,
      builder: (context, state) {
        if (state.featuredDestinations.isEmpty) return const SliverToBoxAdapter();
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Featured',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.88),
                  itemCount: state.featuredDestinations.length,
                  itemBuilder: (context, index) {
                    final dest = state.featuredDestinations[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: DestinationCard(
                        destination: dest,
                        onTap: () => context.push(
                          RouteNames.tourismDestinationDetailPath(dest.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDestinationGrid() {
    return BlocBuilder<DestinationListBloc, DestinationListState>(
      builder: (context, state) {
        if (state.status == DestinationListStatus.loading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == DestinationListStatus.error &&
            state.destinations.isEmpty) {
          return SliverFillRemaining(
            child: _ErrorView(
              message: state.errorMessage ?? 'Failed to load destinations',
              onRetry: () => context
                  .read<DestinationListBloc>()
                  .add(const DestinationListRefreshed()),
            ),
          );
        }
        if (state.destinations.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No destinations found')),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dest = state.destinations[index];
                return DestinationCard(
                  destination: dest,
                  onTap: () => context.push(
                    RouteNames.tourismDestinationDetailPath(dest.id),
                  ),
                );
              },
              childCount: state.destinations.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return BlocBuilder<DestinationListBloc, DestinationListState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        if (state.status != DestinationListStatus.loadingMore) {
          return const SliverToBoxAdapter();
        }
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_outlined,
            size: 64, color: AppColors.outline),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
