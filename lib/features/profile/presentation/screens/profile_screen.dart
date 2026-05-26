import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/error/error_view.dart';
import 'package:vibyuk/core/widgets/loaders/skeleton_loader.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';
import 'package:vibyuk/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:vibyuk/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:vibyuk/features/profile/presentation/widgets/profile_stats_row.dart';
import 'package:vibyuk/features/profile/presentation/widgets/social_links_display.dart';
import 'package:vibyuk/features/profile/presentation/widgets/verified_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadMyProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is AccountDeletedState) {
          context.read<AuthBloc>().add(const LogoutEvent());
        }
      },
      child: Scaffold(
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileLoadingState() => _ProfileSkeleton(),
              ProfileLoadedState(:final profile) => _ProfileContent(profile: profile),
              ProfileUpdatedState(:final profile) => _ProfileContent(profile: profile),
              ProfileUpdatingState(:final currentProfile) =>
                _ProfileContent(profile: currentProfile),
              ProfileErrorState(:final failure, :final currentProfile) =>
                currentProfile != null
                    ? _ProfileContent(profile: currentProfile)
                    : ErrorView(
                        message: failure.message,
                        onRetry: () => context.read<ProfileBloc>().add(const LoadMyProfileEvent()),
                      ),
              _ => _ProfileSkeleton(),
            };
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileEntity profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _ProfileSliverAppBar(profile: profile),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _NameRow(profile: profile),
                if (profile.bio != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    profile.bio!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                  ),
                ],
                if (profile.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.location!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                ProfileStatsRow(
                  stats: profile.stats,
                  isCreator: profile.isCreator,
                ),
                if (!profile.socialLinks.isEmpty) ...[
                  const SizedBox(height: 24),
                  SocialLinksDisplay(links: profile.socialLinks),
                ],
                if (profile.isCreator && profile.creatorInfo != null) ...[
                  const SizedBox(height: 24),
                  _CreatorInfoSection(info: profile.creatorInfo!),
                ],
                if (profile.isBusiness && profile.businessInfo != null) ...[
                  const SizedBox(height: 24),
                  _BusinessInfoSection(info: profile.businessInfo!),
                ],
                const SizedBox(height: 32),
                _QuickActionsRow(profile: profile),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSliverAppBar extends StatelessWidget {
  final ProfileEntity profile;

  const _ProfileSliverAppBar({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.go(RouteNames.settings),
          tooltip: 'Settings',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (profile.coverImageUrl != null)
              CachedNetworkImage(
                imageUrl: profile.coverImageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _DefaultCover(),
              )
            else
              _DefaultCover(),
            // Gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // Avatar positioned at the bottom
            Positioned(
              bottom: -48,
              left: 20,
              child: ProfileAvatar(
                avatarUrl: profile.user.avatarUrl,
                displayName: profile.user.fullName,
                radius: 48,
                showEditOverlay: true,
                onTap: () => context.go(RouteNames.editProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0030), Color(0xFF0D001A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  final ProfileEntity profile;

  const _NameRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8), // space for avatar
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.user.fullName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (profile.stats.isVerified) ...[
                        const SizedBox(width: 6),
                        const VerifiedBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (profile.user.role != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.brandGradient,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            profile.user.role!.displayName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(RouteNames.editProfile),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CreatorInfoSection extends StatelessWidget {
  final CreatorInfo info;

  const _CreatorInfoSection({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creator Details',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (info.serviceTypes.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: info.serviceTypes
                .map(
                  (s) => Chip(
                    label: Text(s),
                    backgroundColor: AppColors.primaryContainer,
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: const BorderSide(color: Colors.transparent),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Icon(
              Icons.payments_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              info.rateDisplay,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (info.responseRate != null) ...[
              const SizedBox(width: 16),
              Icon(
                Icons.reply_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${info.responseRateDisplay} response rate',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _BusinessInfoSection extends StatelessWidget {
  final BusinessInfo info;

  const _BusinessInfoSection({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Info',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (info.companyName != null)
          _InfoRow(icon: Icons.business_rounded, text: info.companyName!),
        if (info.industry != null)
          _InfoRow(icon: Icons.category_outlined, text: info.industry!),
        if (info.companySize != null)
          _InfoRow(icon: Icons.people_outline_rounded, text: '${info.companySize} employees'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final ProfileEntity profile;

  const _QuickActionsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () => context.go(RouteNames.editProfile),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => context.go(RouteNames.settings),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => context.go(RouteNames.settings),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: SkeletonLoader(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 64),
              SkeletonLoader(child: Container(height: 28, width: 180, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 8),
              SkeletonLoader(child: Container(height: 16, width: 100, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 16),
              SkeletonLoader(child: Container(height: 60, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 24),
              SkeletonLoader(child: Container(height: 80, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)))),
            ]),
          ),
        ),
      ],
    );
  }
}
