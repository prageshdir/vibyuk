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
import 'package:vibyuk/features/creator/presentation/blocs/availability/availability_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/booking_requests/booking_requests_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/campaign_applications/campaign_applications_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_analytics/creator_analytics_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_profile/creator_profile_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/earnings/earnings_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/kyc/kyc_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/portfolio/portfolio_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/pricing/pricing_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/reviews/reviews_bloc.dart';
import 'package:vibyuk/features/creator/presentation/screens/availability_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/booking_requests/booking_request_detail_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/booking_requests/booking_requests_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/campaign_applications/apply_to_campaign_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/campaign_applications/campaign_applications_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/creator_analytics_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/creator_dashboard_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/creator_public_profile_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/earnings_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/kyc_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/onboarding/creator_onboarding_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/portfolio/add_portfolio_item_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/portfolio/portfolio_screen.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
import 'package:vibyuk/features/creator/presentation/screens/pricing/add_edit_pricing_package_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/pricing/pricing_packages_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/reviews_screen.dart';
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

      // Creator — Dashboard
      GoRoute(
        path: RouteNames.creatorDashboard,
        name: 'creator-dashboard',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<CreatorProfileBloc>(),
          child: const CreatorDashboardScreen(),
        ),
      ),

      // Creator — Onboarding
      GoRoute(
        path: RouteNames.creatorOnboarding,
        name: 'creator-onboarding',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<CreatorProfileBloc>(),
          child: const CreatorOnboardingScreen(),
        ),
      ),

      // Creator — Edit Profile
      GoRoute(
        path: RouteNames.editCreatorProfile,
        name: 'edit-creator-profile',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<CreatorProfileBloc>(),
          child: const _PlaceholderScreen(title: 'Edit Profile'),
        ),
      ),

      // Creator — Portfolio
      GoRoute(
        path: RouteNames.creatorPortfolio,
        name: 'creator-portfolio',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<PortfolioBloc>(),
          child: const PortfolioScreen(),
        ),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-portfolio-item',
            builder: (context, _) => BlocProvider(
              create: (_) => sl<PortfolioBloc>(),
              child: const AddPortfolioItemScreen(),
            ),
          ),
        ],
      ),

      // Creator — Pricing
      GoRoute(
        path: RouteNames.creatorPricing,
        name: 'creator-pricing',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<PricingBloc>(),
          child: const PricingPackagesScreen(),
        ),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-pricing-package',
            builder: (context, _) => BlocProvider(
              create: (_) => sl<PricingBloc>(),
              child: const AddEditPricingPackageScreen(),
            ),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'edit-pricing-package',
            builder: (context, state) {
              final pkg = state.extra;
              return BlocProvider(
                create: (_) => sl<PricingBloc>(),
                child: AddEditPricingPackageScreen(
                    existingPackage:
                        pkg as PricingPackageEntity?),
              );
            },
          ),
        ],
      ),

      // Creator — Availability
      GoRoute(
        path: RouteNames.creatorAvailability,
        name: 'creator-availability',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<AvailabilityBloc>(),
          child: const AvailabilityScreen(),
        ),
      ),

      // Creator — Analytics
      GoRoute(
        path: RouteNames.creatorAnalytics,
        name: 'creator-analytics',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<CreatorAnalyticsBloc>(),
          child: const CreatorAnalyticsScreen(),
        ),
      ),

      // Creator — Earnings
      GoRoute(
        path: RouteNames.creatorEarnings,
        name: 'creator-earnings',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<EarningsBloc>(),
          child: const EarningsScreen(),
        ),
      ),

      // Creator — Booking Requests
      GoRoute(
        path: RouteNames.creatorBookingRequests,
        name: 'creator-booking-requests',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<BookingRequestsBloc>(),
          child: const BookingRequestsScreen(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'creator-booking-request-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => sl<BookingRequestsBloc>(),
                child: BookingRequestDetailScreen(requestId: id),
              );
            },
          ),
        ],
      ),

      // Creator — Campaign Applications
      GoRoute(
        path: RouteNames.creatorApplications,
        name: 'creator-applications',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<CampaignApplicationsBloc>(),
          child: const CampaignApplicationsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'apply/:campaignId',
            name: 'apply-to-campaign',
            builder: (context, state) {
              final campaignId = state.pathParameters['campaignId']!;
              final campaignTitle =
                  state.uri.queryParameters['title'] ?? 'Campaign';
              return BlocProvider(
                create: (_) => sl<CampaignApplicationsBloc>(),
                child: ApplyToCampaignScreen(
                  campaignId: campaignId,
                  campaignTitle: campaignTitle,
                ),
              );
            },
          ),
        ],
      ),

      // Creator — Reviews
      GoRoute(
        path: RouteNames.creatorReviews,
        name: 'creator-reviews',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<ReviewsBloc>(),
          child: const ReviewsScreen(),
        ),
      ),

      // Creator — KYC
      GoRoute(
        path: RouteNames.creatorKyc,
        name: 'creator-kyc',
        builder: (context, _) => BlocProvider(
          create: (_) => sl<KycBloc>()..add(const LoadKycStatusEvent()),
          child: const KycScreen(),
        ),
      ),

      // Creator — Public Profile
      GoRoute(
        path: '/creators/:id/preview',
        name: 'creator-public-profile',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<CreatorProfileBloc>()),
              BlocProvider(create: (_) => sl<PortfolioBloc>()),
              BlocProvider(create: (_) => sl<ReviewsBloc>()),
            ],
            child: CreatorPublicProfileScreen(creatorId: id),
          );
        },
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
