import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/discovery/discovery_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';

class CreatorDetailScreen extends StatefulWidget {
  final String creatorId;

  const CreatorDetailScreen({super.key, required this.creatorId});

  @override
  State<CreatorDetailScreen> createState() => _CreatorDetailScreenState();
}

class _CreatorDetailScreenState extends State<CreatorDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load creator detail via a search with ID — bloc handles caching
    context.read<DiscoveryBloc>().add(
          ExecuteSearchEvent(
            query: widget.creatorId,
            filters: const _IdSearchFilters(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (context, state) {
        CreatorEntity? creator;
        if (state is DiscoveryLoadedState) {
          try {
            creator = state.creators
                .firstWhere((c) => c.id == widget.creatorId);
          } catch (_) {
            creator = state.creators.isNotEmpty ? state.creators.first : null;
          }
        }

        if (state is DiscoveryLoadingState) {
          return const Scaffold(body: Center(child: AppLoader()));
        }

        if (creator == null) {
          return Scaffold(
            appBar: AppBar(),
            body: BusinessEmptyState(
              title: 'Creator not found',
              description: 'This creator profile is no longer available.',
              icon: Icons.person_off_rounded,
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            ),
          );
        }

        return _CreatorDetailView(creator: creator);
      },
    );
  }
}

class _IdSearchFilters extends SearchFiltersEntity {
  const _IdSearchFilters() : super();
}

class _CreatorDetailView extends StatelessWidget {
  final CreatorEntity creator;
  const _CreatorDetailView({required this.creator});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            actions: [
              IconButton(
                icon: Icon(
                  creator.isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: Colors.white,
                ),
                onPressed: () =>
                    context.read<DiscoveryBloc>().add(
                          ToggleSaveCreatorEvent(
                            creatorId: creator.id,
                            currentlySaved: creator.isSaved,
                          ),
                        ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _CoverImage(creator: creator),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 20,
                    child: _HeroInfo(creator: creator),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(creator: creator),
                  const SizedBox(height: 20),
                  if (creator.bio != null) ...[
                    Text(
                      'About',
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      creator.bio!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (creator.categories.isNotEmpty) ...[
                    Text(
                      'Categories',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: creator.categories.map((c) {
                        return Chip(
                          label: Text(c),
                          backgroundColor: AppColors.primaryContainer,
                          labelStyle: const TextStyle(
                              color: AppColors.primary, fontSize: 12),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (creator.skills.isNotEmpty) ...[
                    Text(
                      'Skills',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: creator.skills.map((s) {
                        return Chip(
                          label: Text(s),
                          backgroundColor: AppColors.tertiaryContainer,
                          labelStyle: const TextStyle(
                              color: AppColors.onTertiaryContainer,
                              fontSize: 12),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _SocialLinks(creator: creator),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creator.rateDisplay,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'per hour',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Book Creator',
                  onPressed: () => context.push('/bookings/checkout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final CreatorEntity creator;
  const _CoverImage({required this.creator});

  @override
  Widget build(BuildContext context) {
    final url = creator.coverImageUrl ?? creator.avatarUrl;
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _GradientCover(),
      );
    }
    return _GradientCover();
  }
}

class _GradientCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.creatorGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  final CreatorEntity creator;
  const _HeroInfo({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          backgroundImage: creator.avatarUrl != null
              ? NetworkImage(creator.avatarUrl!)
              : null,
          child: creator.avatarUrl == null
              ? Text(
                  creator.initials,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700),
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
                  Expanded(
                    child: Text(
                      creator.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (creator.isVerified)
                    const Icon(Icons.verified_rounded,
                        color: Colors.white, size: 18),
                ],
              ),
              if (creator.location != null)
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      creator.location!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final CreatorEntity creator;
  const _StatsRow({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.star_rounded,
          value: creator.rating.toStringAsFixed(1),
          label: '${creator.reviewsCount} reviews',
          color: AppColors.warning,
        ),
        _Separator(),
        _StatItem(
          icon: Icons.calendar_today_rounded,
          value: '${creator.totalBookings}',
          label: 'bookings',
          color: AppColors.primary,
        ),
        _Separator(),
        _StatItem(
          icon: Icons.people_rounded,
          value: _formatCount(creator.followersCount),
          label: 'followers',
          color: AppColors.secondary,
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.outlineVariant);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _SocialLinks extends StatelessWidget {
  final CreatorEntity creator;
  const _SocialLinks({required this.creator});

  @override
  Widget build(BuildContext context) {
    final hasSocials = creator.instagram != null ||
        creator.twitter != null ||
        creator.tiktok != null;
    if (!hasSocials) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Media',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            if (creator.instagram != null)
              _SocialChip(
                  label: '@${creator.instagram}',
                  icon: Icons.camera_alt_rounded),
            if (creator.twitter != null)
              _SocialChip(
                  label: '@${creator.twitter}',
                  icon: Icons.alternate_email_rounded),
            if (creator.tiktok != null)
              _SocialChip(
                  label: '@${creator.tiktok}',
                  icon: Icons.music_note_rounded),
          ],
        ),
      ],
    );
  }
}

class _SocialChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SocialChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.primaryContainer,
      side: BorderSide.none,
    );
  }
}
