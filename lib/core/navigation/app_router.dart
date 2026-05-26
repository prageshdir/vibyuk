import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/navigation/guards/auth_guard.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
// Auth
import 'package:vibyuk/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/login_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/phone_otp_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/register_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/splash_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/verify_email_screen.dart';
// Business
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
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
import 'package:vibyuk/features/business/presentation/screens/search_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/invoice_screen.dart' as biz_invoice;
import 'package:vibyuk/features/business/presentation/screens/notification_center_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/payment_analytics_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/payment_detail_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/payment_overview_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/saved_creators_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/creator_comparison_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/team_screen.dart';
import 'package:vibyuk/features/business/presentation/screens/transaction_history_screen.dart';
// Creator
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
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
import 'package:vibyuk/features/creator/presentation/screens/edit_creator_profile_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/creator_public_profile_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/bank_account_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/earnings_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/kyc_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/onboarding/creator_onboarding_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/portfolio/add_portfolio_item_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/portfolio/portfolio_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/pricing/add_edit_pricing_package_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/pricing/pricing_packages_screen.dart';
import 'package:vibyuk/features/creator/presentation/screens/reviews_screen.dart';
// Booking Engine
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart' as be_entity;
import 'package:vibyuk/features/booking_engine/domain/entities/booking_reschedule_entity.dart' as be_reschedule_entity;
import 'package:vibyuk/features/booking_engine/presentation/blocs/booking_detail/booking_detail_bloc.dart' as be_detail_bloc;
import 'package:vibyuk/features/booking_engine/presentation/blocs/booking_engine/booking_engine_bloc.dart' as be_bloc;
import 'package:vibyuk/features/booking_engine/presentation/blocs/contract/contract_bloc.dart' as be_contract_bloc;
import 'package:vibyuk/features/booking_engine/presentation/blocs/dispute/dispute_bloc.dart' as be_dispute_bloc;
import 'package:vibyuk/features/booking_engine/presentation/blocs/invoice/invoice_bloc.dart' as be_invoice_bloc;
import 'package:vibyuk/features/booking_engine/presentation/blocs/milestone/milestone_bloc.dart' as be_milestone_bloc;
import 'package:vibyuk/features/booking_engine/presentation/blocs/negotiation/negotiation_bloc.dart' as be_negotiation_bloc;
import 'package:vibyuk/features/booking_engine/presentation/blocs/reschedule/reschedule_bloc.dart' as be_reschedule_bloc;
import 'package:vibyuk/features/booking_engine/presentation/blocs/timeline/timeline_bloc.dart' as be_timeline_bloc;
import 'package:vibyuk/features/booking_engine/presentation/screens/booking_detail_screen.dart' as be_booking_detail;
import 'package:vibyuk/features/booking_engine/presentation/screens/booking_list_screen.dart' as be_booking_list;
import 'package:vibyuk/features/booking_engine/presentation/screens/confirmation/booking_confirmation_screen.dart';
import 'package:vibyuk/features/booking_engine/presentation/screens/contract/contract_screen.dart';
import 'package:vibyuk/features/booking_engine/presentation/screens/dispute/dispute_screen.dart';
import 'package:vibyuk/features/booking_engine/presentation/screens/history/booking_history_screen.dart';
import 'package:vibyuk/features/booking_engine/presentation/screens/invoice/invoice_screen.dart';
import 'package:vibyuk/features/booking_engine/presentation/screens/milestones/milestones_screen.dart';
import 'package:vibyuk/features/booking_engine/presentation/screens/negotiation/negotiation_screen.dart';
import 'package:vibyuk/features/booking_engine/presentation/screens/reschedule/reschedule_screen.dart';
import 'package:vibyuk/features/booking_engine/presentation/screens/timeline/timeline_screen.dart';
// Profile
import 'package:vibyuk/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:vibyuk/features/profile/presentation/screens/profile_screen.dart';
import 'package:vibyuk/features/profile/presentation/screens/settings_screen.dart';
// Chat
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';
import 'package:vibyuk/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:vibyuk/features/chat/presentation/blocs/conversations/conversations_bloc.dart';
import 'package:vibyuk/features/chat/presentation/screens/chat_screen.dart';
import 'package:vibyuk/features/chat/presentation/screens/conversations_screen.dart';
// AI
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';
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
import 'package:vibyuk/features/ai/presentation/screens/ai_recommendations_screen.dart';
// Admin
import 'package:vibyuk/features/admin/presentation/bloc/admin_analytics/admin_analytics_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_disputes/admin_disputes_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_moderation/admin_moderation_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_reports/admin_reports_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_verification/admin_verification_bloc.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_analytics_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_disputes_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_moderation_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_announcements_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_fee_config_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_financial_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:vibyuk/features/admin/presentation/screens/admin_verification_screen.dart';
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
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/campaign_list/campaign_list_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/creator_collaboration/creator_collaboration_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/destination_detail/destination_detail_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/destination_list/destination_list_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/fam_trip/fam_trip_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/tourism_analytics/tourism_analytics_cubit.dart';
import 'package:vibyuk/features/tourism/presentation/screens/campaign_list_screen.dart';
import 'package:vibyuk/features/tourism/presentation/screens/creator_collaboration_screen.dart';
import 'package:vibyuk/features/tourism/presentation/screens/destination_detail_screen.dart';
import 'package:vibyuk/features/tourism/presentation/screens/destination_gallery_screen.dart';
import 'package:vibyuk/features/tourism/presentation/screens/destination_list_screen.dart';
import 'package:vibyuk/features/tourism/presentation/screens/fam_trip_detail_screen.dart';
import 'package:vibyuk/features/tourism/presentation/screens/fam_trip_screen.dart';
import 'package:vibyuk/features/tourism/presentation/screens/tourism_analytics_screen.dart';
import 'package:vibyuk/features/tourism/presentation/screens/tourism_hub_screen.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_dashboard/wedding_dashboard_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_marketplace/wedding_marketplace_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/vendor_detail/vendor_detail_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/venue_detail/venue_detail_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/package_builder/package_builder_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/budget_tracker/budget_tracker_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_timeline/wedding_timeline_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_analytics/wedding_analytics_cubit.dart';
import 'package:vibyuk/features/wedding/presentation/screens/wedding_dashboard_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/wedding_marketplace_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/vendor_detail_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/venue_detail_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/venue_listing_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/package_builder_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/budget_tracker_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/wedding_timeline_screen.dart';
import 'package:vibyuk/features/wedding/presentation/screens/wedding_analytics_screen.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:vibyuk/features/subscriptions/presentation/screens/business_upgrade_screen.dart';
import 'package:vibyuk/features/subscriptions/presentation/screens/subscription_upgrade_screen.dart';
import 'package:vibyuk/features/influencer/presentation/blocs/influencer_campaign/influencer_campaign_bloc.dart';
import 'package:vibyuk/features/influencer/presentation/screens/influencer_campaigns_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/two_factor_setup_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/two_factor_verify_screen.dart';
import 'package:vibyuk/features/auth/presentation/screens/account_suspended_screen.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart' as auth_entities;

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
  AppRouter(this._authGuard, [this._routeObserver]);

  final AuthGuard _authGuard;
  final NavigatorObserver? _routeObserver;

  final navigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = _buildRouter();

  GoRouter _buildRouter() {
    final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    observers: [if (_routeObserver != null) _routeObserver!],
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
      GoRoute(
        path: RouteNames.twoFactorSetup,
        name: '2fa-setup',
        builder: (_, __) => const TwoFactorSetupScreen(),
      ),
      GoRoute(
        path: RouteNames.twoFactorVerify,
        name: '2fa-verify',
        builder: (_, state) {
          final methodStr = state.uri.queryParameters['method'] ?? 'totp';
          final method = auth_entities.TwoFactorMethod.fromString(methodStr) ??
              auth_entities.TwoFactorMethod.totp;
          return TwoFactorVerifyScreen(method: method);
        },
      ),
      GoRoute(
        path: RouteNames.accountSuspended,
        name: 'account-suspended',
        builder: (_, state) {
          final reason = state.uri.queryParameters['reason'];
          final suspendedAtStr = state.uri.queryParameters['suspended_at'];
          final suspendedAt =
              suspendedAtStr != null ? DateTime.tryParse(suspendedAtStr) : null;
          return AccountSuspendedScreen(reason: reason, suspendedAt: suspendedAt);
        },
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
                GoRoute(
                  path: 'compare',
                  name: 'creator-comparison',
                  builder: (context, state) {
                    final ids = state.extra is List<String>
                        ? state.extra! as List<String>
                        : <String>[];
                    // NOTE: comparison loads creator data from cached discovery state
                    return BlocProvider(
                      create: (_) => sl<DiscoveryBloc>(),
                      child: Builder(
                        builder: (ctx) {
                          final discoveryState = ctx.read<DiscoveryBloc>().state;
                          final creators = discoveryState is DiscoveryLoadedState
                              ? discoveryState.creators
                                  .where((c) => ids.contains(c.id))
                                  .toList()
                              : <CreatorEntity>[];
                          return CreatorComparisonScreen(creators: creators);
                        },
                      ),
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
              builder: (context, _) => BlocProvider(
                create: (_) => sl<ConversationsBloc>(),
                child: const ConversationsScreen(),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'chat',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    final conversation = state.extra! as ConversationEntity;
                    return BlocProvider(
                      create: (_) => sl<ChatBloc>(),
                      child: ChatScreen(
                        conversationId: id,
                        otherUserId: conversation.otherUserId,
                        otherUserName: conversation.otherUserName,
                        otherUserAvatarUrl: conversation.otherUserAvatarUrl,
                        bookingId: conversation.bookingId,
                      ),
                    );
                  },
                ),
              ],
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
        builder: (_, __) => BlocProvider(
          create: (_) => sl<DiscoveryBloc>(),
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<NotificationCenterBloc>()),
          ],
          child: const NotificationCenterScreen(),
        ),
        routes: [
          GoRoute(
            path: 'preferences',
            name: 'notification-preferences',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<NotificationPreferencesBloc>(),
              child: const NotificationPreferencesScreen(),
            ),
          ),
        ],
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
      GoRoute(
        path: RouteNames.paymentDetail,
        name: 'payment-detail',
        builder: (context, state) {
          final payment = state.extra as PaymentEntity;
          return PaymentDetailScreen(payment: payment);
        },
      ),
      GoRoute(
        path: RouteNames.transactionHistory,
        name: 'transaction-history',
        builder: (context, _) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.paymentAnalytics,
        name: 'payment-analytics',
        builder: (context, _) => const PaymentAnalyticsScreen(),
      ),
      GoRoute(
        path: '/payments/invoice/:bookingId',
        name: 'biz-invoice-screen',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return biz_invoice.InvoiceScreen(bookingId: bookingId);
        },
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
          child: const EditCreatorProfileScreen(),
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

      // Creator — Bank Account
      GoRoute(
        path: RouteNames.creatorBankAccount,
        name: 'creator-bank-account',
        builder: (context, _) => const CreatorBankAccountScreen(),
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

      // ── Booking Engine ─────────────────────────────────────────────────────

      // Booking list
      GoRoute(
        path: RouteNames.bookingEngineList,
        name: 'booking-engine-list',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<be_bloc.BookingEngineBloc>(),
          child: const be_booking_list.BookingListScreen(),
        ),
      ),

      // Booking history
      GoRoute(
        path: RouteNames.bookingEngineHistory,
        name: 'booking-engine-history',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<be_bloc.BookingEngineBloc>(),
          child: const BookingHistoryScreen(),
        ),
      ),

      // Booking detail + sub-screens
      GoRoute(
        path: '/booking-engine/bookings/:id',
        name: 'booking-engine-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<be_detail_bloc.BookingDetailBloc>(),
            child: be_booking_detail.BookingDetailScreen(bookingId: id),
          );
        },
        routes: [
          GoRoute(
            path: 'confirmation',
            name: 'booking-engine-confirmation',
            builder: (context, state) {
              final booking = state.extra! as be_entity.BookingEntity;
              return BookingConfirmationScreen(booking: booking);
            },
          ),
          GoRoute(
            path: 'negotiation',
            name: 'booking-engine-negotiation',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final currentUserId =
                  state.uri.queryParameters['userId'] ?? '';
              return BlocProvider(
                create: (_) => sl<be_negotiation_bloc.NegotiationBloc>(),
                child: NegotiationScreen(
                  bookingId: id,
                  currentUserId: currentUserId,
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
            path: 'contract',
            name: 'booking-engine-contract',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => sl<be_contract_bloc.ContractBloc>(),
                child: ContractScreen(bookingId: id),
              );
            },
          ),
          GoRoute(
            path: 'milestones',
            name: 'booking-engine-milestones',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final isCreator =
                  state.uri.queryParameters['isCreator'] == 'true';
              return BlocProvider(
                create: (_) => sl<be_milestone_bloc.MilestoneBloc>(),
                child: MilestonesScreen(
                  bookingId: id,
                  isCreator: isCreator,
                ),
              );
            },
          ),
          GoRoute(
            path: 'timeline',
            name: 'booking-engine-timeline',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => sl<be_timeline_bloc.TimelineBloc>(),
                child: TimelineScreen(bookingId: id),
              );
            },
          ),
          GoRoute(
            path: 'dispute',
            name: 'booking-engine-dispute',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final currentUserId =
                  state.uri.queryParameters['userId'] ?? '';
              return BlocProvider(
                create: (_) => sl<be_dispute_bloc.DisputeBloc>(),
                child: DisputeScreen(
                  bookingId: id,
                  currentUserId: currentUserId,
                ),
              );
            },
          ),
          GoRoute(
            path: 'reschedule',
            name: 'booking-engine-reschedule',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final currentUserId =
                  state.uri.queryParameters['userId'] ?? '';
              final reschedule =
                  state.extra as be_reschedule_entity.BookingRescheduleEntity?;
              return BlocProvider(
                create: (_) => sl<be_reschedule_bloc.RescheduleBloc>(),
                child: RescheduleScreen(
                  bookingId: id,
                  currentUserId: currentUserId,
                  existingReschedule: reschedule,
                ),
              );
            },
          ),
          GoRoute(
            path: 'invoice',
            name: 'booking-engine-invoice',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => sl<be_invoice_bloc.InvoiceBloc>(),
                child: InvoiceScreen(bookingId: id),
              );
            },
          ),
          GoRoute(
            path: 'dashboard',
            name: 'event-dashboard',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => sl<EventDashboardBloc>(),
                child: EventDashboardScreen(eventId: id),
              );
            },
          ),
        ],
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
      GoRoute(
        path: RouteNames.adminAnnouncements,
        name: 'admin-announcements',
        builder: (_, __) => const AdminAnnouncementsScreen(),
      ),
      GoRoute(
        path: RouteNames.adminFeeConfig,
        name: 'admin-fee-config',
        builder: (_, __) => const AdminFeeConfigScreen(),
      ),
      GoRoute(
        path: RouteNames.adminFinancial,
        name: 'admin-financial',
        builder: (_, __) => const AdminFinancialScreen(),
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
        path: '/wedding/venues/:id',
        name: 'wedding-venue-detail',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<VenueDetailBloc>(),
          child: VenueDetailScreen(venueId: state.pathParameters['id']!),
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

      // ── Tourism Promotion ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.tourism,
        name: 'tourism-hub',
        builder: (_, __) => const TourismHubScreen(),
      ),
      GoRoute(
        path: RouteNames.tourismDestinations,
        name: 'tourism-destinations',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<DestinationListBloc>(),
          child: const DestinationListScreen(),
        ),
      ),
      GoRoute(
        path: '/tourism/destinations/:id',
        name: 'tourism-destination-detail',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<DestinationDetailBloc>(),
          child: DestinationDetailScreen(
              id: state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'gallery',
            name: 'tourism-destination-gallery',
            builder: (context, state) {
              final destination = state.extra as TourismDestinationEntity?;
              if (destination == null) {
                return const _PlaceholderScreen(title: 'Gallery');
              }
              return DestinationGalleryScreen(destination: destination);
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.tourismCampaigns,
        name: 'tourism-campaigns',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (_) => GetIt.instance<CampaignListBloc>(),
            child: CampaignListScreen(
              destinationId: extra?['destinationId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/tourism/campaigns/:id',
        name: 'tourism-campaign-detail',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<CampaignListBloc>(),
          child: CampaignListScreen(
            destinationId: null,
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.famTrips,
        name: 'fam-trips',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (_) => GetIt.instance<FamTripBloc>(),
            child: FamTripScreen(
              destinationId: extra?['destinationId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.famTripDetail,
        name: 'fam-trip-detail',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<FamTripBloc>(),
          child: FamTripDetailScreen(
            tripId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.tourismCollaborations,
        name: 'tourism-collaborations',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (_) => GetIt.instance<CreatorCollaborationBloc>(),
            child: CreatorCollaborationScreen(
              destinationId: extra?['destinationId'] as String?,
              campaignId: extra?['campaignId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.tourismAnalyticsDashboard,
        name: 'tourism-analytics',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<TourismAnalyticsCubit>(),
          child: const TourismAnalyticsScreen(),
        ),
      ),

      // Subscriptions
      GoRoute(
        path: RouteNames.subscriptionUpgrade,
        name: 'subscription-upgrade',
        builder: (_, __) => BlocProvider.value(
          value: GetIt.instance<SubscriptionBloc>(),
          child: const SubscriptionUpgradeScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.businessSubscriptionUpgrade,
        name: 'business-subscription-upgrade',
        builder: (_, state) {
          final plan = state.extra is BusinessPlan
              ? state.extra! as BusinessPlan
              : BusinessPlan.free;
          return BusinessUpgradeScreen(currentPlan: plan);
        },
      ),
      GoRoute(
        path: RouteNames.influencerCampaigns,
        name: 'influencer-campaigns',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<InfluencerCampaignBloc>()
            ..add(const LoadInfluencerCampaignsEvent()),
          child: const InfluencerCampaignsScreen(),
        ),
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
