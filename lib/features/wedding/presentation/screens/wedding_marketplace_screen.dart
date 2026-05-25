import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_marketplace/wedding_marketplace_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/venue_card.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/wedding_vendor_card.dart';

class WeddingMarketplaceScreen extends StatefulWidget {
  const WeddingMarketplaceScreen({super.key});

  @override
  State<WeddingMarketplaceScreen> createState() =>
      _WeddingMarketplaceScreenState();
}

class _WeddingMarketplaceScreenState extends State<WeddingMarketplaceScreen> {
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  static const _categories = [
    'photographer',
    'videographer',
    'florist',
    'caterer',
    'band',
    'dj',
    'hair_makeup',
    'cake',
    'transport',
    'decor',
  ];

  @override
  void initState() {
    super.initState();
    context
        .read<WeddingMarketplaceBloc>()
        .add(const WeddingMarketplaceVendorsRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<WeddingMarketplaceBloc>().state;
    if (state is! WeddingMarketplaceLoaded) return;
    if (!_scrollController.position.atEdge ||
        _scrollController.position.pixels == 0) return;

    if (state.showingVenues && state.hasMoreVenues) {
      context
          .read<WeddingMarketplaceBloc>()
          .add(const WeddingMarketplaceLoadMoreVenues());
    } else if (!state.showingVenues && state.hasMoreVendors) {
      context
          .read<WeddingMarketplaceBloc>()
          .add(const WeddingMarketplaceLoadMoreVendors());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBar(
                  hintText: 'Search vendors...',
                  leading: const Icon(Icons.search),
                  onChanged: (q) {
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                      context
                          .read<WeddingMarketplaceBloc>()
                          .add(WeddingMarketplaceSearchChanged(query: q));
                    });
                  },
                ),
              ),
              _CategoryRow(),
            ],
          ),
        ),
        actions: [
          BlocBuilder<WeddingMarketplaceBloc, WeddingMarketplaceState>(
            builder: (context, state) {
              final showingVenues =
                  state is WeddingMarketplaceLoaded && state.showingVenues;
              return IconButton(
                icon: Icon(showingVenues
                    ? Icons.people_outline
                    : Icons.location_city_outlined),
                tooltip: showingVenues ? 'Show Vendors' : 'Show Venues',
                onPressed: () => context
                    .read<WeddingMarketplaceBloc>()
                    .add(const WeddingMarketplaceVenueToggled()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WeddingMarketplaceBloc, WeddingMarketplaceState>(
        builder: (context, state) => switch (state) {
          WeddingMarketplaceInitial() ||
          WeddingMarketplaceLoading() =>
            const Center(child: CircularProgressIndicator()),
          WeddingMarketplaceError(:final failure) => Center(
              child: Text(failure.message),
            ),
          WeddingMarketplaceLoaded() => _LoadedBody(
              state: state,
              scrollController: _scrollController,
            ),
        },
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  static const _cats = [
    'photographer',
    'videographer',
    'florist',
    'caterer',
    'band',
    'dj',
    'decor',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeddingMarketplaceBloc, WeddingMarketplaceState>(
      builder: (context, state) {
        final selected =
            state is WeddingMarketplaceLoaded ? state.selectedCategory : null;
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All'),
                  selected: selected == null,
                  onSelected: (_) => context
                      .read<WeddingMarketplaceBloc>()
                      .add(const WeddingMarketplaceCategoryChanged()),
                ),
              ),
              ..._cats.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_label(cat)),
                      selected: selected == cat,
                      onSelected: (_) => context
                          .read<WeddingMarketplaceBloc>()
                          .add(WeddingMarketplaceCategoryChanged(category: cat)),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  String _label(String cat) => cat
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

class _LoadedBody extends StatelessWidget {
  final WeddingMarketplaceLoaded state;
  final ScrollController scrollController;
  const _LoadedBody({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (state.showingVenues) {
      return _VenueGrid(venues: state.venues, controller: scrollController);
    }
    return _VendorGrid(vendors: state.vendors, controller: scrollController);
  }
}

class _VendorGrid extends StatelessWidget {
  final List vendors;
  final ScrollController controller;
  const _VendorGrid({required this.vendors, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (vendors.isEmpty) {
      return const Center(child: Text('No vendors found'));
    }
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: vendors.length,
      itemBuilder: (context, i) => WeddingVendorCard(
        vendor: vendors[i],
        onTap: () => context.push(
          RouteNames.weddingVendorDetailPath(vendors[i].id),
        ),
      ),
    );
  }
}

class _VenueGrid extends StatelessWidget {
  final List venues;
  final ScrollController controller;
  const _VenueGrid({required this.venues, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (venues.isEmpty) {
      return const Center(child: Text('No venues found'));
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      itemCount: venues.length,
      itemBuilder: (context, i) => VenueCard(
        venue: venues[i],
        onTap: () {},
      ),
    );
  }
}
