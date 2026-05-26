import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';



class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _DashboardHeader(),
              title: const Text(
                'Admin Panel',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            backgroundColor: AppColors.electricViolet,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Quick Access',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _QuickAccessCard(
                      title: 'User Moderation',
                      subtitle: 'Manage & moderate users',
                      icon: Icons.people_alt_rounded,
                      color: AppColors.electricViolet,
                      onTap: () => context.push(RouteNames.adminModeration),
                    ),
                    _QuickAccessCard(
                      title: 'Disputes',
                      subtitle: 'Review open disputes',
                      icon: Icons.gavel_rounded,
                      color: AppColors.vibrantCoral,
                      onTap: () => context.push(RouteNames.adminDisputes),
                    ),
                    _QuickAccessCard(
                      title: 'Verifications',
                      subtitle: 'Review ID requests',
                      icon: Icons.verified_rounded,
                      color: AppColors.neonTeal,
                      onTap: () => context.push(RouteNames.adminVerifications),
                    ),
                    _QuickAccessCard(
                      title: 'Analytics',
                      subtitle: 'Platform performance',
                      icon: Icons.analytics_rounded,
                      color: const Color(0xFFFFB020),
                      onTap: () => context.push(RouteNames.adminAnalytics),
                    ),
                    _QuickAccessCard(
                      title: 'Reports',
                      subtitle: 'Handle user reports',
                      icon: Icons.flag_rounded,
                      color: const Color(0xFFFF8C42),
                      onTap: () => context.push(RouteNames.adminReports),
                    ),
                    _QuickAccessCard(
                      title: 'Announcements',
                      subtitle: 'Send bulk notifications',
                      icon: Icons.campaign_rounded,
                      color: const Color(0xFF1B998B),
                      onTap: () => context.push(RouteNames.adminAnnouncements),
                    ),
                    _QuickAccessCard(
                      title: 'Fee Config',
                      subtitle: 'Platform commission rates',
                      icon: Icons.percent_rounded,
                      color: const Color(0xFF8338EC),
                      onTap: () => context.push(RouteNames.adminFeeConfig),
                    ),
                    _QuickAccessCard(
                      title: 'Financial',
                      subtitle: 'Payouts & commission ledger',
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFF06D6A0),
                      onTap: () => context.push(RouteNames.adminFinancial),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B2FFF), Color(0xFF4A1BCC)],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.45),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
