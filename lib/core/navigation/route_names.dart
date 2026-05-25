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
  static const String eventList = '/events';
  static const String eventDetail = '/events/:id';
  static const String createEvent = '/events/create';
  static const String editEventRoute = '/events/:id/edit';
  static String editEventPath(String id) => '/events/$id/edit';
  static const String purchaseTickets = '/events/:id/purchase';
  static String purchaseTicketsPath(String id) => '/events/$id/purchase';
  static const String eventDashboard = '/events/:id/dashboard';
  static String eventDashboardPath(String id) => '/events/$id/dashboard';

  // Bookings
  static const String bookingDetail = '/bookings/:id';
  static const String bookingCheckout = '/bookings/checkout';
  static const String bookingConfirmation = '/bookings/:id/confirmation';

  // Profile
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notifications/:id';
  static const String notificationPreferences = '/notifications/preferences';

  // Tickets
  static const String myTickets = '/tickets';
  static const String ticketDetail = '/tickets/:id';
  static const String ticketScanner = '/scanner';

  // Misc
  static const String search = '/search';

  // Wedding
  static const String weddingDashboard = '/wedding';
  static const String weddingMarketplace = '/wedding/marketplace';
  static const String weddingVendorDetail = '/wedding/vendors/:id';
  static String weddingVendorDetailPath(String id) => '/wedding/vendors/$id';
  static const String weddingVenueListing = '/wedding/venues';
  static const String weddingVenueDetail = '/wedding/venues/:id';
  static String weddingVenueDetailPath(String id) => '/wedding/venues/$id';
  static const String weddingPackageBuilder = '/wedding/packages/build';
  static const String weddingBudgetTracker = '/wedding/budget';
  static const String weddingTimeline = '/wedding/timeline';
  static const String weddingAnalytics = '/wedding/analytics';

  RouteNames._();
}
