import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/navigation/guards/auth_guard.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/login_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/phone_otp_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/register_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/splash_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:vibyuk/features/business/presentation/blocs/analytics/analytics_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/booking/booking_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/campaign/campaign_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/discovery/discovery_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/payment/payment_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/team/team_bloc.dart';
import 'package:vibyuk/features/business/presentation/screens/analytics_dashboard_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/bookings/booking_detail_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/bookings/booking_list_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/campaigns/campaign_detail_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/campaigns/campaign_list_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/campaigns/create_campaign_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/creator_detail_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/discover_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/notification_center_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/payment_overview_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/saved_creators_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/team_screen.dart';
import 'package:vibyuk/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:vibyuk/features/profile/presentation/screens/profile_screen.dart';
import 'package:vibyuk/features/profile/presentation/screens/settings_screen.dart';

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
            Text('Page not found',
                style: Theme.of(context).textTheme.headlineMedium),
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
        builder: (_, __) => const SplashScreen(),
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
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'reset-password',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        name: 'verify-email',
        builder: (_, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: RouteNames.phoneOtp,
        name: 'phone-otp',
        builder: (_, __) => const PhoneOtpScreen(),
      ),
      GoRoute(
        path: RouteNames.roleSelection,
        name: 'role-selection',
        builder: (_, __) => const RoleSelectionScreen(),
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
              builder: (_, __) =>
                  const _PlaceholderScreen(title: 'Home'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.discover,
              name: 'discover',
              builder: (context, _) => BlocProvider(
                create: (_) => sl<DiscoveryBloc>(),
                child: const DiscoverScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'saved',
                  name: 'saved-creators',
                  builder: (context, _) => BlocProvider(
                    create: (_) => sl<DiscoveryBloc>(),
                    child: const SavedCreatorsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'creators/:id',
                  name: 'creator-detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return BlocProvider(
                      create: (_) => sl<DiscoveryBloc>(),
                      child: CreatorDetailScreen(creatorId: id),
                    );
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.bookings,
              name: 'bookings',
              builder: (context, _) => BlocProvider(
                create: (_) => sl<BookingBloc>(),
                child: const BookingListScreen(),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'booking-detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return BlocProvider(
                      create: (_) => sl<BookingBloc>(),
                      child: BookingDetailScreen(bookingId: id),
                    );
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.messages,
              name: 'messages',
              builder: (_, __) =>
                  const _PlaceholderScreen(title: 'Messages'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.profile,
              name: 'profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'edit-profile',
                  builder: (_, __) => const EditProfileScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),

      // Global overlays
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.search,
        name: 'search',
        builder: (_, __) => const _PlaceholderScreen(title: 'Search'),
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<NotificationsBloc>(),
          child: const NotificationCenterScreen(),
        ),
      ),

      // Business — Campaigns
      GoRoute(
        path: RouteNames.campaigns,
        name: 'campaigns',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<CampaignBloc>(),
          child: const CampaignListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'create',
            name: 'create-campaign',
            builder: (context, _) => BlocProvider(
              create: (_) => sl<CampaignBloc>(),
              child: const CreateCampaignScreen(),
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'campaign-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => sl<CampaignBloc>(),
                child: CampaignDetailScreen(campaignId: id),
              );
            },
          ),
        ],
      ),

      // Business — Team
      GoRoute(
        path: RouteNames.team,
        name: 'team',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<TeamBloc>(),
          child: const TeamScreen(),
        ),
      ),

      // Business — Analytics
      GoRoute(
        path: RouteNames.analytics,
        name: 'analytics',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<AnalyticsBloc>(),
          child: const AnalyticsDashboardScreen(),
        ),
      ),

      // Business — Payments
      GoRoute(
        path: RouteNames.payments,
        name: 'payments',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<PaymentBloc>(),
          child: const PaymentOverviewScreen(),
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
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Discover'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Bookings'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Messages'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}
