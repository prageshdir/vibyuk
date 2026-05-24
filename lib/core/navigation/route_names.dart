abstract final class RouteNames {
  // Shell / Root
  static const String root = '/';
  static const String shell = '/shell';

  // Auth
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String phoneOtp = '/auth/phone-otp';
  static const String roleSelection = '/auth/role-selection';

  // Home (tab shell)
  static const String home = '/home';
  static const String discover = '/discover';
  static const String bookings = '/bookings';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Creators
  static const String creatorDetail = '/creators/:id';
  static const String creatorPortfolio = '/creators/:id/portfolio';

  // Events
  static const String eventDetail = '/events/:id';
  static const String createEvent = '/events/create';
  static const String editEvent = '/events/:id/edit';

  // Bookings
  static const String bookingDetail = '/bookings/:id';
  static const String bookingCheckout = '/bookings/checkout';
  static const String bookingConfirmation = '/bookings/:id/confirmation';

  // Profile
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Misc
  static const String search = '/search';

  // Business — Discovery
  static const String savedCreators = '/discover/saved';

  // Business — Campaigns
  static const String campaigns = '/campaigns';

  // Business — Team
  static const String team = '/team';

  // Business — Analytics
  static const String analytics = '/analytics';

  // Business — Payments
  static const String payments = '/payments';

  RouteNames._();
}
