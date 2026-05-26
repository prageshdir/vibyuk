import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_profile/creator_profile_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/creator_dashboard_stats.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CreatorProfileBloc>().add(const LoadCreatorProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocBuilder<CreatorProfileBloc, CreatorProfileState>(
        builder: (context, state) => switch (state) {
          CreatorProfileLoadingState() =>
            const Center(child: AppLoader()),
          CreatorProfileLoadedState(:final profile) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (profile.coverImageUrl != null)
                          Image.network(profile.coverImageUrl!,
                              fit: BoxFit.cover)
                        else
                          Container(color: AppColors.primary.withValues(alpha: 0.3)),
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
                                radius: 32,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    profile.profileImageUrl != null
                                        ? NetworkImage(profile.profileImageUrl!)
                                        : null,
                                child: profile.profileImageUrl == null
                                    ? Text(
                                        profile.displayName[0].toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(profile.displayName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800)),
                                    if (profile.location != null)
                                      Text(profile.location!,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13)),
                                  ],
                                ),
                              ),
                              if (profile.isVerified)
                                const Icon(Icons.verified_rounded,
                                    color: Colors.blue, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.push(RouteNames.editCreatorProfile),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push(RouteNames.settings),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Onboarding banner
                      if (!profile.isOnboardingComplete)
                        _OnboardingBanner(profile: profile),

                      const SizedBox(height: 16),
                      Text('Overview',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      CreatorDashboardStats(profile: profile),
                      const SizedBox(height: 24),
                      Text('Quick Actions',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _QuickActionsGrid(),
                    ]),
                  ),
                ),
              ],
            ),
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
                        .add(const LoadCreatorProfileEvent()),
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

class _OnboardingBanner extends StatelessWidget {
  const _OnboardingBanner({required this.profile});
  final CreatorProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_outlined, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Complete your profile',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                Text('Finish setup to start receiving bookings',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(RouteNames.creatorOnboarding),
            style:
                TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionTile(
          icon: Icons.photo_library_outlined,
          label: 'Portfolio',
          route: RouteNames.creatorPortfolio),
      _ActionTile(
          icon: Icons.sell_outlined,
          label: 'Pricing',
          route: RouteNames.creatorPricing),
      _ActionTile(
          icon: Icons.calendar_month_outlined,
          label: 'Availability',
          route: RouteNames.creatorAvailability),
      _ActionTile(
          icon: Icons.inbox_outlined,
          label: 'Requests',
          route: RouteNames.creatorBookingRequests),
      _ActionTile(
          icon: Icons.campaign_outlined,
          label: 'Campaigns',
          route: RouteNames.creatorApplications),
      _ActionTile(
          icon: Icons.currency_rupee_rounded,
          label: 'Earnings',
          route: RouteNames.creatorEarnings),
      _ActionTile(
          icon: Icons.bar_chart_rounded,
          label: 'Analytics',
          route: RouteNames.creatorAnalytics),
      _ActionTile(
          icon: Icons.verified_user_outlined,
          label: 'KYC',
          route: RouteNames.creatorKyc),
      _ActionTile(
          icon: Icons.account_balance_outlined,
          label: 'Bank A/C',
          route: RouteNames.creatorBankAccount),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => actions[i],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
