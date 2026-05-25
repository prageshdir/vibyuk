import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/pagination/pagination_event.dart';
import 'package:vibyuk/core/pagination/pagination_state.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_list/event_list_bloc.dart';
import 'package:vibyuk/features/events/presentation/widgets/event_card.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  EventCategory? _selectedCategory;
  bool _myEventsOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventListBloc>().add(const FetchFirstPage<EventEntity>());
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<EventListBloc>().state;
    if (state is PaginationLoaded<EventEntity> &&
        !state.isFetchingMore &&
        !state.hasReachedEnd) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll - 200) {
        context
            .read<EventListBloc>()
            .add(const FetchNextPage<EventEntity>());
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context
          .read<EventListBloc>()
          .add(EventSearchChanged(query: query));
    });
  }

  void _onCategoryTap(EventCategory? category) {
    setState(() => _selectedCategory = category);
    context
        .read<EventListBloc>()
        .add(EventCategoryFilterChanged(category: category));
  }

  void _toggleMyEvents(bool value) {
    setState(() => _myEventsOnly = value);
    context
        .read<EventListBloc>()
        .add(EventMyEventsToggled(myEventsOnly: value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<EventListBloc>()
              .add(const RefreshPage<EventEntity>());
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 80,
              flexibleSpace: const FlexibleSpaceBar(
                title: Text('Events'),
                titlePadding: EdgeInsets.only(left: 16, bottom: 12),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => showSearch(
                    context: context,
                    delegate: _EventSearchDelegate(
                      onSearch: (q) => _onSearchChanged(q),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _CategoryFilterBar(
                selected: _selectedCategory,
                myEventsOnly: _myEventsOnly,
                onCategoryTap: _onCategoryTap,
                onMyEventsToggled: _toggleMyEvents,
              ),
            ),
            BlocBuilder<EventListBloc, PaginationState<EventEntity>>(
              builder: (context, state) {
                if (state is PaginationLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is PaginationEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No events found'),
                        ],
                      ),
                    ),
                  );
                }
                if (state is PaginationError && !state.hasPreviousData) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(state.failure.message),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context
                                .read<EventListBloc>()
                                .add(const FetchFirstPage<EventEntity>()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = state is PaginationLoaded<EventEntity>
                    ? state.items
                    : (state as PaginationError<EventEntity>).previousItems;
                final isFetchingMore = state is PaginationLoaded<EventEntity>
                    ? state.isFetchingMore
                    : false;

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == items.length) {
                          return isFetchingMore
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox.shrink();
                        }
                        return EventCard(
                          event: items[index],
                          onTap: () =>
                              context.push('/events/${items[index].id}'),
                        );
                      },
                      childCount: items.length + (isFetchingMore ? 1 : 0),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.createEvent),
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final EventCategory? selected;
  final bool myEventsOnly;
  final void Function(EventCategory?) onCategoryTap;
  final void Function(bool) onMyEventsToggled;

  const _CategoryFilterBar({
    required this.selected,
    required this.myEventsOnly,
    required this.onCategoryTap,
    required this.onMyEventsToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('My Events'),
              selected: myEventsOnly,
              onSelected: onMyEventsToggled,
            ),
          ),
          FilterChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onCategoryTap(null),
          ),
          ...EventCategory.values.map((cat) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: Text(_categoryLabel(cat)),
                  selected: selected == cat,
                  onSelected: (_) => onCategoryTap(selected == cat ? null : cat),
                ),
              )),
        ],
      ),
    );
  }

  String _categoryLabel(EventCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }
}

class _EventSearchDelegate extends SearchDelegate<String> {
  final void Function(String) onSearch;

  _EventSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            onSearch('');
          },
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => BackButton(
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return const Center(child: Text('Searching...'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }
}
