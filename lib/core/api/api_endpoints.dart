abstract final class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String googleSignIn = '/auth/google';
  static const String sendPhoneOtp = '/auth/phone/send-otp';
  static const String verifyPhoneOtp = '/auth/phone/verify-otp';
  static const String selectRole = '/auth/role';
  static const String registerBiometric = '/auth/biometric/register';

  // User / Profile
  static const String me = '/users/me';
  static const String updateProfile = '/users/me';
  static const String changePassword = '/users/me/password';
  static const String uploadAvatar = '/users/me/avatar';
  static const String deleteAccount = '/users/me';
  static const String notificationSettings = '/users/me/notification-settings';
  static String userProfile(String id) => '/users/$id';

  // Creators
  static const String creators = '/creators';
  static String creator(String id) => '/creators/$id';
  static String creatorPortfolio(String id) => '/creators/$id/portfolio';
  static String creatorReviews(String id) => '/creators/$id/reviews';

  // Events
  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String eventAttendees(String id) => '/events/$id/attendees';

  // Bookings
  static const String bookings = '/bookings';
  static String booking(String id) => '/bookings/$id';
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static String confirmBooking(String id) => '/bookings/$id/confirm';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static const String registerDeviceToken = '/notifications/device-tokens';

  // Media
  static const String uploadMedia = '/media/upload';
  static String deleteMedia(String id) => '/media/$id';

  // Search
  static const String search = '/search';
  static const String searchCreators = '/search/creators';
  static const String searchEvents = '/search/events';

  // Creator — Profile
  static const String creatorMe = '/creator/me';
  static const String creatorMeProfileImage = '/creator/me/profile-image';
  static const String creatorMeCoverImage = '/creator/me/cover-image';
  static const String creatorMeOnboarding = '/creator/me/onboarding';
  static String creatorPublicProfile(String id) => '/creator/$id/public';

  // Creator — Portfolio
  static const String creatorPortfolioItems = '/creator/me/portfolio';
  static String creatorPortfolioItem(String id) => '/creator/me/portfolio/$id';
  static const String creatorPortfolioReorder = '/creator/me/portfolio/reorder';

  // Creator — Pricing
  static const String creatorPricingPackages = '/creator/me/pricing';
  static String creatorPricingPackage(String id) => '/creator/me/pricing/$id';

  // Creator — Availability
  static const String creatorAvailability = '/creator/me/availability';
  static const String creatorAvailabilityDays = '/creator/me/availability/days';
  static const String creatorAvailabilitySlots = '/creator/me/availability/slots';
  static const String creatorAvailabilityBlock = '/creator/me/availability/block';

  // Creator — Analytics
  static const String creatorAnalytics = '/creator/me/analytics';

  // Creator — Earnings
  static const String creatorEarnings = '/creator/me/earnings';
  static const String creatorPayoutRequest = '/creator/me/earnings/payout';

  // Creator — Booking Requests
  static const String creatorBookingRequests = '/creator/me/booking-requests';
  static String creatorBookingRequest(String id) => '/creator/me/booking-requests/$id';
  static String creatorBookingRequestRespond(String id) =>
      '/creator/me/booking-requests/$id/respond';

  // Creator — Campaign Applications
  static const String creatorApplications = '/creator/me/applications';
  static String creatorApplication(String id) => '/creator/me/applications/$id';
  static String creatorApplicationWithdraw(String id) =>
      '/creator/me/applications/$id/withdraw';
  static String campaignApply(String campaignId) => '/campaigns/$campaignId/apply';

  // Creator — Reviews
  static const String creatorReviewsMe = '/creator/me/reviews';

  // Creator — KYC
  static const String creatorKyc = '/creator/me/kyc';
}
