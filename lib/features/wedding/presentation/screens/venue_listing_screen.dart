import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_marketplace/wedding_marketplace_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/venue_card.dart';

class VenueListingScreen extends StatefulWidget {
  const VenueListingScreen({super.key});

  @override
  State<VenueListingScreen> createState() => _VenueListingScreenState();
}

class _VenueListingScreenState extends State<VenueListingScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<WeddingMarketplaceBloc>()
        .add(const WeddingMarketplaceVenuesRequested());
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        context
            .read<WeddingMarketplaceBloc>()
            .add(const WeddingMarketplaceLoadMoreVenues());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venues')),
      body: BlocBuilder<WeddingMarketplaceBloc, WeddingMarketplaceState>(
        builder: (context, state) => switch (state) {
          WeddingMarketplaceInitial() ||
          WeddingMarketplaceLoading() =>
            const Center(child: CircularProgressIndicator()),
          WeddingMarketplaceError(:final failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(failure.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WeddingMarketplaceBloc>().add(
                          const WeddingMarketplaceVenuesRequested(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          WeddingMarketplaceLoaded(:final venues, :final isLoadingMore) =>
            venues.isEmpty
                ? const Center(child: Text('No venues available'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: venues.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == venues.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: VenueCard(
                          venue: venues[i],
                          onTap: () {},
                        ),
                      );
                    },
                  ),
        },
      ),
    );
  }
}
