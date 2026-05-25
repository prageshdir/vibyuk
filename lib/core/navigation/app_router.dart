import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/navigation/guards/auth_guard.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_analytics/ai_analytics_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_campaign/ai_campaign_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_chat/ai_chat_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_insights/ai_insights_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_pricing/ai_pricing_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_recommendations/ai_recommendations_bloc.dart';
import 'package:vibyuk/features/ai/presentation/screens/ai_analytics_screen.dart';
import 'package:vibyuk/features/ai/presentation/screens/ai_campaign_planner_screen.dart';
import 'package:vibyuk/features/ai/presentation/screens/ai_chat_screen.dart';
import 'package:vibyuk/features/ai/presentation/screens/ai_hub_screen.dart';
import 'package:vibyuk/features/ai/presentation/screens/ai_pricing_screen.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';
import 'package:vibyuk/features/ai/presentation/screens/ai_recommendations_screen.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_analytics/admin_analytics_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_disputes/admin_disputes_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_moderation/admin_moderation_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_reports/admin_reports_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_verification/admin_verification_bloc.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_analytics_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_disputes_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_moderation_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_verification_screen.dart';

// Placeholder screens — replaced by feature modules as they are built
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

class AppRouter {
  AppRouter(this._authGuard);

  final AuthGuard _authGuard;

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: _authGuard.redirect,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (_, __) => const _PlaceholderScreen(title: 'Splash'),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (_, __) => const _PlaceholderScreen(title: 'Onboarding'),
      ),

      // Auth routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (_, __) => const _PlaceholderScreen(title: 'Login'),
        routes: [
          GoRoute(
            path: 'forgot-password',
            name: 'forgot-password',
            builder: (_, __) => const _PlaceholderScreen(title: 'Forgot Password'),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (_, __) => const _PlaceholderScreen(title: 'Register'),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'reset-password',
        builder: (_, __) => const _PlaceholderScreen(title: 'Reset Password'),
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        name: 'verify-email',
        builder: (_, __) => const _PlaceholderScreen(title: 'Verify Email'),
      ),

      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _ScaffoldWithNavBar(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.home,
              name: 'home',
              builder: (_, __) => const _PlaceholderScreen(title: 'Home'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.discover,
              name: 'discover',
              builder: (_, __) => const _PlaceholderScreen(title: 'Discover'),
              routes: [
                GoRoute(
                  path: 'creators/:id',
                  name: 'creator-detail',
                  builder: (context, state) => _PlaceholderScreen(
                    title: 'Creator ${state.pathParameters['id']}',
                  ),
                ),
                GoRoute(
                  path: 'events/:id',
                  name: 'event-detail',
                  builder: (context, state) => _PlaceholderScreen(
                    title: 'Event ${state.pathParameters['id']}',
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.bookings,
              name: 'bookings',
              builder: (_, __) => const _PlaceholderScreen(title: 'Bookings'),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'booking-detail',
                  builder: (context, state) => _PlaceholderScreen(
                    title: 'Booking ${state.pathParameters['id']}',
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.messages,
              name: 'messages',
              builder: (_, __) => const _PlaceholderScreen(title: 'Messages'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.profile,
              name: 'profile',
              builder: (_, __) => const _PlaceholderScreen(title: 'Profile'),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'edit-profile',
                  builder: (_, __) => const _PlaceholderScreen(title: 'Edit Profile'),
                ),
                GoRoute(
                  path: 'settings',
                  name: 'settings',
                  builder: (_, __) => const _PlaceholderScreen(title: 'Settings'),
                ),
              ],
            ),
          ]),
        ],
      ),

      // Global overlays (push above shell)
      GoRoute(
        path: RouteNames.search,
        name: 'search',
        builder: (_, __) => const _PlaceholderScreen(title: 'Search'),
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (_, __) => const _PlaceholderScreen(title: 'Notifications'),
      ),

      // AI Feature Routes
      GoRoute(
        path: RouteNames.aiHub,
        name: 'ai-hub',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<AiInsightsBloc>(),
          child: const AiHubScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.aiRecommendations,
        name: 'ai-recommendations',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<AiRecommendationsBloc>(),
          child: const AiRecommendationsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.aiCampaignPlanner,
        name: 'ai-campaign-planner',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<AiCampaignBloc>(),
          child: const AiCampaignPlannerScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.aiPricing,
        name: 'ai-pricing',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<AiPricingBloc>(),
          child: const AiPricingScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.aiAnalytics,
        name: 'ai-analytics',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<AiAnalyticsBloc>(),
          child: const AiAnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.aiChat,
        name: 'ai-chat',
        builder: (context, state) {
          final contextParam =
              state.uri.queryParameters['context'] ?? 'general';
          final chatCtx = AiChatContext.values.firstWhere(
            (c) => c.name == contextParam,
            orElse: () => AiChatContext.general,
          );
          return BlocProvider(
            create: (_) => sl<AiChatBloc>(),
            child: AiChatScreen(chatContext: chatCtx),
          );
        },
      ),

      // Admin Routes
      GoRoute(
        path: RouteNames.adminDashboard,
        name: 'admin-dashboard',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.adminModeration,
        name: 'admin-moderation',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AdminModerationBloc>(),
          child: const AdminModerationScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.adminDisputes,
        name: 'admin-disputes',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AdminDisputesBloc>(),
          child: const AdminDisputesScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.adminVerifications,
        name: 'admin-verifications',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AdminVerificationBloc>(),
          child: const AdminVerificationScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.adminAnalytics,
        name: 'admin-analytics',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AdminAnalyticsBloc>(),
          child: const AdminAnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.adminReports,
        name: 'admin-reports',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<AdminReportsBloc>(),
          child: const AdminReportsScreen(),
        ),
      ),
    ],
  );
}

class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
