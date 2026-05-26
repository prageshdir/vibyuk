import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthenticatedState ? state.user : null;
        final role = user?.role;
        return switch (role) {
          UserRole.creator => _CreatorHome(user: user!),
          UserRole.business => _BusinessHome(user: user!),
          _ => const _LoadingHome(),
        };
      },
    );
  }
}

class _LoadingHome extends StatelessWidget {
  const _LoadingHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// ── Creator Home ─────────────────────────────────────────────────────────────

class _CreatorHome extends StatelessWidget {
  final UserEntity user;
  const _CreatorHome({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )),
                Text(user.firstName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push(RouteNames.notifications),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _QuickActionRow(actions: [
                  _QuickAction(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    color: AppColors.primary,
                    onTap: () => context.push(RouteNames.creatorDashboard),
                  ),
                  _QuickAction(
                    icon: Icons.calendar_month_outlined,
                    label: 'Bookings',
                    color: const Color(0xFF4CAF50),
                    onTap: () => context.push(RouteNames.bookings),
                  ),
                  _QuickAction(
                    icon: Icons.currency_rupee_rounded,
                    label: 'Earnings',
                    color: const Color(0xFFFF9800),
                    onTap: () => context.push(RouteNames.creatorEarnings),
                  ),
                  _QuickAction(
                    icon: Icons.campaign_outlined,
                    label: 'Campaigns',
                    color: const Color(0xFF9C27B0),
                    onTap: () => context.push(RouteNames.creatorApplications),
                  ),
                ]),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Explore',
                  onSeeAll: () => context.push(RouteNames.tourismDestinations),
                ),
                const SizedBox(height: 12),
                _ExploreCard(
                  icon: Icons.travel_explore,
                  title: 'Tourism Campaigns',
                  subtitle: 'FAM trips and destination collabs',
                  color: const Color(0xFF2196F3),
                  onTap: () => context.push(RouteNames.tourism),
                ),
                const SizedBox(height: 8),
                _ExploreCard(
                  icon: Icons.event_outlined,
                  title: 'Events',
                  subtitle: 'Discover and join local events',
                  color: const Color(0xFFE91E63),
                  onTap: () => context.push(RouteNames.eventList),
                ),
                const SizedBox(height: 8),
                _ExploreCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI Tools',
                  subtitle: 'Pricing engine, campaign planner',
                  color: AppColors.primary,
                  onTap: () => context.push(RouteNames.aiHub),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Business Home ─────────────────────────────────────────────────────────────

class _BusinessHome extends StatelessWidget {
  final UserEntity user;
  const _BusinessHome({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    )),
                Text(user.firstName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push(RouteNames.notifications),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _QuickActionRow(actions: [
                  _QuickAction(
                    icon: Icons.explore_outlined,
                    label: 'Discover',
                    color: AppColors.primary,
                    onTap: () => context.push(RouteNames.discover),
                  ),
                  _QuickAction(
                    icon: Icons.campaign_outlined,
                    label: 'Campaigns',
                    color: const Color(0xFF4CAF50),
                    onTap: () => context.push(RouteNames.campaigns),
                  ),
                  _QuickAction(
                    icon: Icons.bar_chart_rounded,
                    label: 'Analytics',
                    color: const Color(0xFFFF9800),
                    onTap: () => context.push(RouteNames.analytics),
                  ),
                  _QuickAction(
                    icon: Icons.auto_awesome_outlined,
                    label: 'AI Tools',
                    color: const Color(0xFF9C27B0),
                    onTap: () => context.push(RouteNames.aiHub),
                  ),
                ]),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Quick Links',
                ),
                const SizedBox(height: 12),
                _ExploreCard(
                  icon: Icons.celebration_outlined,
                  title: 'Wedding Planning',
                  subtitle: 'Vendors, venues, budget tracker',
                  color: const Color(0xFFE91E63),
                  onTap: () => context.push('/wedding'),
                ),
                const SizedBox(height: 8),
                _ExploreCard(
                  icon: Icons.travel_explore,
                  title: 'Tourism Campaigns',
                  subtitle: 'Creator collaborations & FAM trips',
                  color: const Color(0xFF2196F3),
                  onTap: () => context.push(RouteNames.tourism),
                ),
                const SizedBox(height: 8),
                _ExploreCard(
                  icon: Icons.event_outlined,
                  title: 'Events',
                  subtitle: 'Create events and sell tickets',
                  color: const Color(0xFF4CAF50),
                  onTap: () => context.push(RouteNames.eventList),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _QuickActionRow extends StatelessWidget {
  final List<_QuickAction> actions;
  const _QuickActionRow({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions,
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See all'),
          ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
