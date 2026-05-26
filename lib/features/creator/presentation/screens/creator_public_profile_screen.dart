import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_profile/creator_profile_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/portfolio/portfolio_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/reviews/reviews_bloc.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';
import 'package:vibyuk/features/creator/presentation/widgets/portfolio_item_card.dart';
import 'package:vibyuk/features/creator/presentation/widgets/review_card.dart';

class CreatorPublicProfileScreen extends StatefulWidget {
  const CreatorPublicProfileScreen({super.key, required this.creatorId});

  final String creatorId;

  @override
  State<CreatorPublicProfileScreen> createState() =>
      _CreatorPublicProfileScreenState();
}

class _CreatorPublicProfileScreenState
    extends State<CreatorPublicProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CreatorProfileBloc>().add(
          LoadPublicCreatorProfileEvent(creatorId: widget.creatorId),
        );
    context.read<PortfolioBloc>().add(const LoadPortfolioEvent());
    context.read<ReviewsBloc>().add(const LoadReviewsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CreatorProfileBloc, CreatorProfileState>(
        builder: (context, state) => switch (state) {
          CreatorProfileLoadingState() =>
            const Center(child: AppLoader()),
          CreatorProfileLoadedState(:final profile) =>
            _ProfileView(profile: profile),
          CreatorProfileErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<CreatorProfileBloc>()
                        .add(LoadPublicCreatorProfileEvent(
                            creatorId: widget.creatorId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.profile});
  final CreatorProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        // Cover + avatar header
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (profile.coverImageUrl != null)
                  Image.network(profile.coverImageUrl!, fit: BoxFit.cover)
                else
                  Container(color: AppColors.primary.withOpacity(0.3)),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage: profile.profileImageUrl != null
                            ? NetworkImage(profile.profileImageUrl!)
                            : null,
                        child: profile.profileImageUrl == null
                            ? Text(
                                profile.displayName[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    profile.displayName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (profile.isVerified) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded,
                                      color: Colors.blue, size: 18),
                                ],
                              ],
                            ),
                            if (profile.location != null)
                              Text(
                                profile.location!,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats row
              _StatsRow(profile: profile),
              const SizedBox(height: 20),

              // Availability chip
              _AvailabilityBadge(status: profile.availabilityStatus),
              const SizedBox(height: 20),

              // Bio
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                Text('About',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(profile.bio!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                const SizedBox(height: 20),
              ],

              // Categories
              if (profile.categories.isNotEmpty) ...[
                Text('Categories',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.categories
                      .map((c) => Chip(
                            label: Text(c,
                                style: const TextStyle(fontSize: 12)),
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Social links
              if (profile.socialLinks.isNotEmpty) ...[
                Text('Social',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.socialLinks
                      .map((l) => _SocialChip(link: l))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Portfolio preview
              Text('Portfolio',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              BlocBuilder<PortfolioBloc, PortfolioState>(
                builder: (context, state) {
                  if (state is PortfolioLoadingState) {
                    return const Center(child: AppLoader(size: 24));
                  }
                  if (state is PortfolioLoadedState &&
                      state.items.isNotEmpty) {
                    final preview = state.items.take(6).toList();
                    return _PortfolioPreviewGrid(items: preview);
                  }
                  return Text('No portfolio items yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant));
                },
              ),
              const SizedBox(height: 20),

              // Reviews preview
              Text('Reviews',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              BlocBuilder<ReviewsBloc, ReviewsState>(
                builder: (context, state) {
                  if (state is ReviewsLoadingState) {
                    return const Center(child: AppLoader(size: 24));
                  }
                  if (state is ReviewsLoadedState &&
                      state.reviews.isNotEmpty) {
                    final preview = state.reviews.take(3).toList();
                    return Column(
                      children: preview
                          .map((r) => ReviewCard(review: r))
                          .toList(),
                    );
                  }
                  return Text('No reviews yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant));
                },
              ),
              const SizedBox(height: 32),

              // Book now CTA
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Book Now'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final CreatorProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _Stat(
          label: 'Rating',
          value: profile.rating.toStringAsFixed(1),
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
        ),
        _VerticalDivider(),
        _Stat(
          label: 'Reviews',
          value: profile.reviewCount.toString(),
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: theme.colorScheme.primary,
        ),
        _VerticalDivider(),
        _Stat(
          label: 'Completed',
          value: profile.completedBookings.toString(),
          icon: Icons.check_circle_outline_rounded,
          iconColor: Colors.green,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.iconColor});
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3));
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.status});
  final CreatorAvailabilityStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CreatorAvailabilityStatus.available => ('Available for bookings', Colors.green),
      CreatorAvailabilityStatus.busy => ('Currently busy', Colors.orange),
      CreatorAvailabilityStatus.unavailable => ('Not available', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PortfolioPreviewGrid extends StatelessWidget {
  const _PortfolioPreviewGrid({required this.items});
  final List<PortfolioItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => PortfolioItemCard(item: items[i]),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.link});
  final SocialLinkEntity link;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.link_rounded, size: 14),
      label: Text(link.platform,
          style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
