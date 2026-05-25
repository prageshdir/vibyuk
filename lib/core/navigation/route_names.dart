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

  // AI Features
  static const String aiHub = '/ai';
  static const String aiRecommendations = '/ai/recommendations';
  static const String aiCampaignPlanner = '/ai/campaign-planner';
  static const String aiPricing = '/ai/pricing';
  static const String aiAnalytics = '/ai/analytics';
  static const String aiChat = '/ai/chat';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminModeration = '/admin/moderation';
  static const String adminDisputes = '/admin/disputes';
  static const String adminVerifications = '/admin/verifications';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminReports = '/admin/reports';

  RouteNames._();
}
