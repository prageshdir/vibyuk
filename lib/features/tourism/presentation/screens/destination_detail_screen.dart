import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/destination_detail/destination_detail_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/campaign_banner.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/destination_card.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/destination_hero_widget.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/gallery_grid_widget.dart';

class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context
        .read<DestinationDetailBloc>()
        .add(DestinationDetailLoaded(widget.id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DestinationDetailBloc, DestinationDetailState>(
      builder: (context, state) {
        if (state.status == DestinationDetailStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == DestinationDetailStatus.error ||
            state.destination == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(state.errorMessage ?? 'Destination not found'),
            ),
          );
        }
        return _buildContent(context, state.destination!, state);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    TourismDestinationEntity destination,
    DestinationDetailState state,
  ) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerScrolled) => [
          SliverToBoxAdapter(
            child: DestinationHeroWidget(
              destination: destination,
              height: 300,
              showBackButton: true,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Gallery'),
                  Tab(text: 'Campaigns'),
                  Tab(text: 'FAM Trips'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(destination: destination, similar: state.similarDestinations),
            _GalleryTab(destination: destination),
            _CampaignsTab(destinationId: destination.id),
            _FamTripsTab(destinationId: destination.id),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionBar(context, destination),
    );
  }

  Widget _buildActionBar(
      BuildContext context, TourismDestinationEntity destination) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
                onPressed: () => context.push(
                  RouteNames.tourismDestinationGalleryPath(destination.id),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('View Campaigns'),
                onPressed: () => context.push(
                  RouteNames.tourismCampaigns,
                  extra: {'destinationId': destination.id},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.destination,
    required this.similar,
  });

  final TourismDestinationEntity destination;
  final List<TourismDestinationEntity> similar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickStats(context),
        const SizedBox(height: 20),
        _buildSection(context, 'About', destination.description),
        if (destination.highlights.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildHighlights(context),
        ],
        if (destination.bestTimeToVisit != null) ...[
          const SizedBox(height: 20),
          _buildSection(
              context, 'Best Time to Visit', destination.bestTimeToVisit!),
        ],
        const SizedBox(height: 20),
        _buildCostInfo(context),
        if (destination.tags.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildTags(context),
        ],
        if (similar.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSimilar(context),
        ],
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStat(
            icon: Icons.people_outline,
            value: '${destination.creatorCount}',
            label: 'Creators',
          ),
        ),
        Expanded(
          child: _QuickStat(
            icon: Icons.campaign_outlined,
            value: '${destination.campaignCount}',
            label: 'Campaigns',
          ),
        ),
        Expanded(
          child: _QuickStat(
            icon: Icons.star_outline,
            value: destination.rating.toStringAsFixed(1),
            label: 'Rating',
          ),
        ),
        Expanded(
          child: _QuickStat(
            icon: Icons.attach_money,
            value: destination.formattedCost,
            label: 'Avg/Day',
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                )),
      ],
    );
  }

  Widget _buildHighlights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Highlights',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...destination.highlights.map((h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: AppColors.tertiary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(h)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCostInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average Cost',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
              Text(
                '${destination.formattedCost} per day',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: destination.tags
          .map((t) => Chip(
                label: Text(t),
                labelStyle: const TextStyle(fontSize: 12),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ))
          .toList(),
    );
  }

  Widget _buildSimilar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Similar Destinations',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 220,
              child: DestinationCard(
                destination: similar[index],
                isCompact: true,
                onTap: () => context.push(
                  RouteNames.tourismDestinationDetailPath(similar[index].id),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 16)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ── Gallery Tab ───────────────────────────────────────────────────────────────

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({required this.destination});

  final TourismDestinationEntity destination;

  @override
  Widget build(BuildContext context) {
    if (destination.galleryUrls.isEmpty) {
      return const Center(child: Text('No gallery images available'));
    }
    return GalleryGridWidget(
      imageUrls: destination.galleryUrls,
      onImageTap: (index) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullscreenGalleryViewer(
              imageUrls: destination.galleryUrls,
              initialIndex: index,
            ),
          ),
        );
      },
    );
  }
}

// ── Campaigns Tab ─────────────────────────────────────────────────────────────

class _CampaignsTab extends StatelessWidget {
  const _CampaignsTab({required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign_outlined,
              size: 48, color: AppColors.outline),
          const SizedBox(height: 12),
          const Text('View all campaigns for this destination'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push(
              RouteNames.tourismCampaigns,
              extra: {'destinationId': destinationId},
            ),
            child: const Text('Browse Campaigns'),
          ),
        ],
      ),
    );
  }
}

// ── FAM Trips Tab ─────────────────────────────────────────────────────────────

class _FamTripsTab extends StatelessWidget {
  const _FamTripsTab({required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flight_takeoff, size: 48, color: AppColors.outline),
          const SizedBox(height: 12),
          const Text('Explore FAM trips for creators'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push(
              RouteNames.famTrips,
              extra: {'destinationId': destinationId},
            ),
            child: const Text('View FAM Trips'),
          ),
        ],
      ),
    );
  }
}
