import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/guards/auth_guard.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_dashboard/event_dashboard_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_detail/event_detail_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_form/event_form_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_list/event_list_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/my_tickets/my_tickets_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/ticket_purchase/ticket_purchase_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/ticket_scanner/ticket_scanner_cubit.dart';
import 'package:vibyuk/features/events/presentation/screens/create_edit_event_screen.dart';
import 'package:vibyuk/features/events/presentation/screens/event_dashboard_screen.dart';
import 'package:vibyuk/features/events/presentation/screens/event_detail_screen.dart';
import 'package:vibyuk/features/events/presentation/screens/event_list_screen.dart';
import 'package:vibyuk/features/events/presentation/screens/my_tickets_screen.dart';
import 'package:vibyuk/features/events/presentation/screens/ticket_detail_screen.dart';
import 'package:vibyuk/features/events/presentation/screens/ticket_purchase_screen.dart';
import 'package:vibyuk/features/events/presentation/screens/ticket_scanner_screen.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_preferences/notification_preferences_bloc.dart';
import 'package:vibyuk/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:vibyuk/features/notifications/presentation/screens/notification_preferences_screen.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_dashboard/wedding_dashboard_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_marketplace/wedding_marketplace_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/vendor_detail/vendor_detail_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/package_builder/package_builder_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/budget_tracker/budget_tracker_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_timeline/wedding_timeline_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_analytics/wedding_analytics_cubit.dart';
import 'package:vibyuk/features/wedding/presentation/screens/wedding_dashboard_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/wedding_marketplace_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/vendor_detail_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/venue_listing_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/package_builder_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/budget_tracker_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/wedding_timeline_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/wedding_analytics_screen.dart';

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

  late final GoRouter router = _buildRouter();

  GoRouter _buildRouter() {
    final router = GoRouter(
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
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => GetIt.instance<NotificationCenterBloc>(),
            ),
          ],
          child: const NotificationCenterScreen(),
        ),
        routes: [
          GoRoute(
            path: 'preferences',
            name: 'notification-preferences',
            builder: (_, __) => BlocProvider(
              create: (_) =>
                  GetIt.instance<NotificationPreferencesBloc>(),
              child: const NotificationPreferencesScreen(),
            ),
          ),
        ],
      ),

      // ── Events ──────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.eventList,
        name: 'event-list',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<EventListBloc>(),
          child: const EventListScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.createEvent,
        name: 'create-event',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<EventFormBloc>(),
          child: const CreateEditEventScreen(),
        ),
      ),
      GoRoute(
        path: '/events/:id',
        name: 'event-detail-full',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<EventDetailBloc>(),
          child: EventDetailScreen(eventId: state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit-event',
            builder: (context, state) => BlocProvider(
              create: (_) => GetIt.instance<EventFormBloc>(),
              child: CreateEditEventScreen(
                eventId: state.pathParameters['id'],
              ),
            ),
          ),
          GoRoute(
            path: 'purchase',
            name: 'purchase-tickets',
            builder: (context, state) {
              final event = state.extra as EventEntity?;
              if (event == null) {
                return const _PlaceholderScreen(title: 'Purchase Tickets');
              }
              return BlocProvider(
                create: (_) => GetIt.instance<TicketPurchaseBloc>(),
                child: TicketPurchaseScreen(event: event),
              );
            },
          ),
          GoRoute(
            path: 'dashboard',
            name: 'event-dashboard',
            builder: (context, state) => BlocProvider(
              create: (_) => GetIt.instance<EventDashboardBloc>(),
              child: EventDashboardScreen(
                eventId: state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),

      // ── Tickets ─────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.myTickets,
        name: 'my-tickets',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<MyTicketsBloc>(),
          child: const MyTicketsScreen(),
        ),
      ),
      GoRoute(
        path: '/tickets/:id',
        name: 'ticket-detail',
        builder: (context, state) {
          final ticket = state.extra as TicketEntity?;
          if (ticket == null) {
            return const _PlaceholderScreen(title: 'Ticket');
          }
          return TicketDetailScreen(ticket: ticket);
        },
      ),

      // ── Scanner ─────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.ticketScanner,
        name: 'ticket-scanner',
        builder: (context, state) {
          final eventId = state.uri.queryParameters['eventId'] ?? '';
          return BlocProvider(
            create: (_) => GetIt.instance<TicketScannerCubit>(),
            child: TicketScannerScreen(eventId: eventId),
          );
        },
      ),

      // ── Wedding Ecosystem ────────────────────────────────────────────────────
      GoRoute(
        path: '/wedding',
        name: 'wedding-dashboard',
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (_) => GetIt.instance<WeddingDashboardBloc>()),
          ],
          child: const WeddingDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/wedding/marketplace',
        name: 'wedding-marketplace',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<WeddingMarketplaceBloc>(),
          child: const WeddingMarketplaceScreen(),
        ),
      ),
      GoRoute(
        path: '/wedding/vendors/:id',
        name: 'wedding-vendor-detail',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<VendorDetailBloc>(),
          child: VendorDetailScreen(vendorId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/wedding/venues',
        name: 'wedding-venues',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<WeddingMarketplaceBloc>(),
          child: const VenueListingScreen(),
        ),
      ),
      GoRoute(
        path: '/wedding/packages/build',
        name: 'wedding-package-builder',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<PackageBuilderBloc>(),
          child: const PackageBuilderScreen(),
        ),
      ),
      GoRoute(
        path: '/wedding/budget',
        name: 'wedding-budget',
        builder: (context, state) {
          final weddingId = state.uri.queryParameters['weddingId'] ?? '';
          return BlocProvider(
            create: (_) => GetIt.instance<BudgetTrackerBloc>(),
            child: BudgetTrackerScreen(weddingId: weddingId),
          );
        },
      ),
      GoRoute(
        path: '/wedding/timeline',
        name: 'wedding-timeline',
        builder: (context, state) {
          final weddingId = state.uri.queryParameters['weddingId'] ?? '';
          return BlocProvider(
            create: (_) => GetIt.instance<WeddingTimelineBloc>(),
            child: WeddingTimelineScreen(weddingId: weddingId),
          );
        },
      ),
      GoRoute(
        path: '/wedding/analytics',
        name: 'wedding-analytics',
        builder: (context, state) {
          final weddingId = state.uri.queryParameters['weddingId'] ?? '';
          return BlocProvider(
            create: (_) => GetIt.instance<WeddingAnalyticsCubit>(),
            child: WeddingAnalyticsScreen(weddingId: weddingId),
          );
        },
      ),
    ],
    );
    return router;
  }
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
