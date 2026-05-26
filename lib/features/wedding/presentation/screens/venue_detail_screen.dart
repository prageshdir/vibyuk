import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/venue_detail/venue_detail_bloc.dart';

class VenueDetailScreen extends StatefulWidget {
  final String venueId;
  const VenueDetailScreen({super.key, required this.venueId});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<VenueDetailBloc>()
        .add(VenueDetailLoadRequested(venueId: widget.venueId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VenueDetailBloc, VenueDetailState>(
        builder: (context, state) => switch (state) {
          VenueDetailInitial() || VenueDetailLoading() =>
            const Center(child: CircularProgressIndicator()),
          VenueDetailError(:final failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<VenueDetailBloc>().add(
                          VenueDetailLoadRequested(venueId: widget.venueId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          VenueDetailLoaded(:final venue) => _VenueBody(venue: venue),
        },
      ),
    );
  }
}

class _VenueBody extends StatelessWidget {
  final WeddingVenueEntity venue;
  const _VenueBody({required this.venue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(venue.name),
            background: venue.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: venue.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: theme.colorScheme.surfaceContainerHighest),
                  )
                : Container(color: theme.colorScheme.surfaceContainerHighest),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(venue.location, style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text('${venue.rating.toStringAsFixed(1)} (${venue.reviewCount})',
                      style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(
                      icon: Icons.people_outline,
                      label: '${venue.minimumGuests}–${venue.capacity} guests'),
                  const SizedBox(width: 8),
                  _InfoChip(
                      icon: Icons.currency_rupee_rounded,
                      label: '₹${venue.pricePerHead.toStringAsFixed(0)}/head'),
                  if (!venue.isAvailable) ...[
                    const SizedBox(width: 8),
                    _InfoChip(
                        icon: Icons.block,
                        label: 'Unavailable',
                        color: theme.colorScheme.error),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Text('About', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(venue.description, style: theme.textTheme.bodyMedium),
              if (venue.amenities.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Amenities',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: venue.amenities
                      .map((a) => Chip(
                            label: Text(a, style: theme.textTheme.labelSmall),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
              if (venue.galleryUrls.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Gallery',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: venue.galleryUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: venue.galleryUrls[i],
                        width: 160,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 160,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: c)),
        ],
      ),
    );
  }
}
