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
  static const String publicCreatorPortfolio = '/creators/:id/portfolio';

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

  // Creator — Dashboard & Onboarding
  static const String creatorDashboard = '/creator/dashboard';
  static const String creatorOnboarding = '/creator/onboarding';
  static const String editCreatorProfile = '/creator/profile/edit';

  // Creator — Portfolio
  static const String creatorPortfolio = '/creator/portfolio';
  static const String addPortfolioItem = '/creator/portfolio/add';

  // Creator — Pricing
  static const String creatorPricing = '/creator/pricing';
  static const String addPricingPackage = '/creator/pricing/add';
  static String editPricingPackage(String id) => '/creator/pricing/$id/edit';

  // Creator — Availability
  static const String creatorAvailability = '/creator/availability';

  // Creator — Analytics & Earnings
  static const String creatorAnalytics = '/creator/analytics';
  static const String creatorEarnings = '/creator/earnings';

  // Creator — Booking Requests
  static const String creatorBookingRequests = '/creator/bookings';
  static String creatorBookingRequestDetail(String id) =>
      '/creator/bookings/$id';

  // Creator — Campaign Applications
  static const String creatorApplications = '/creator/applications';
  static String applyToCampaign(String campaignId) =>
      '/creator/applications/apply/$campaignId';

  // Creator — Reviews & KYC
  static const String creatorReviews = '/creator/reviews';
  static const String creatorKyc = '/creator/kyc';

  // Creator — Public Profile
  static String creatorPublicProfile(String id) => '/creators/$id/preview';

  // Booking Engine — List & History
  static const String bookingEngineList = '/booking-engine/bookings';
  static const String bookingEngineHistory = '/booking-engine/history';

  // Booking Engine — Detail & Sub-screens
  static String bookingEngineDetail(String id) =>
      '/booking-engine/bookings/$id';
  static String bookingEngineConfirmation(String id) =>
      '/booking-engine/bookings/$id/confirmation';
  static String bookingEngineNegotiation(String id) =>
      '/booking-engine/bookings/$id/negotiation';
  static String bookingEngineContract(String id) =>
      '/booking-engine/bookings/$id/contract';
  static String bookingEngineMilestones(String id) =>
      '/booking-engine/bookings/$id/milestones';
  static String bookingEngineTimeline(String id) =>
      '/booking-engine/bookings/$id/timeline';
  static String bookingEngineDispute(String id) =>
      '/booking-engine/bookings/$id/dispute';
  static String bookingEngineReschedule(String id) =>
      '/booking-engine/bookings/$id/reschedule';
  static String bookingEngineInvoice(String id) =>
      '/booking-engine/bookings/$id/invoice';

  RouteNames._();
}
