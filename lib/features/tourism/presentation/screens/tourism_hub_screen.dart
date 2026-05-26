import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class TourismHubScreen extends StatelessWidget {
  const TourismHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Tourism'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.travel_explore, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Explore & Collaborate',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover destinations, join campaigns and FAM trips',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                _HubCard(
                  icon: Icons.explore_outlined,
                  title: 'Destinations',
                  subtitle: 'Discover curated travel destinations',
                  color: const Color(0xFF2196F3),
                  onTap: () => context.push(RouteNames.tourismDestinations),
                ),
                const SizedBox(height: 12),
                _HubCard(
                  icon: Icons.campaign_outlined,
                  title: 'Campaigns',
                  subtitle: 'Join tourism marketing campaigns',
                  color: const Color(0xFF4CAF50),
                  onTap: () => context.push(RouteNames.tourismCampaigns),
                ),
                const SizedBox(height: 12),
                _HubCard(
                  icon: Icons.flight_takeoff_outlined,
                  title: 'FAM Trips',
                  subtitle: 'Familiarisation trips from tourism boards',
                  color: const Color(0xFFFF9800),
                  onTap: () => context.push(RouteNames.famTrips),
                ),
                const SizedBox(height: 12),
                _HubCard(
                  icon: Icons.handshake_outlined,
                  title: 'Collaborations',
                  subtitle: 'Partner with destinations as a creator',
                  color: const Color(0xFF9C27B0),
                  onTap: () => context.push(RouteNames.tourismCollaborations),
                ),
                const SizedBox(height: 12),
                _HubCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Analytics',
                  subtitle: 'Performance insights for your campaigns',
                  color: AppColors.primary,
                  onTap: () => context.push(RouteNames.tourismAnalyticsDashboard),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
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
