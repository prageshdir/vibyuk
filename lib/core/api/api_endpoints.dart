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

  // User / Profile
  static const String me = '/users/me';
  static const String updateProfile = '/users/me';
  static const String changePassword = '/users/me/password';
  static const String uploadAvatar = '/users/me/avatar';
  static const String deleteAccount = '/users/me';

  // Creators
  static const String creators = '/creators';
  static String creator(String id) => '/creators/$id';
  static String creatorPortfolio(String id) => '/creators/$id/portfolio';
  static String creatorReviews(String id) => '/creators/$id/reviews';

  // Events
  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String eventById(String id) => '/events/$id';
  static String eventAttendees(String id) => '/events/$id/attendees';
  static String eventTicketTypes(String id) => '/events/$id/ticket-types';
  static String eventTicketType(String eventId, String typeId) =>
      '/events/$eventId/ticket-types/$typeId';
  static String eventAnalytics(String id) => '/events/$id/analytics';
  static String publishEvent(String id) => '/events/$id/publish';
  static String cancelEvent(String id) => '/events/$id/cancel';
  static String purchaseTickets(String eventId) =>
      '/events/$eventId/tickets/purchase';
  static String verifyTicket(String eventId) =>
      '/events/$eventId/tickets/verify';
  static String uploadEventCover(String eventId) =>
      '/events/$eventId/cover-image';

  // Bookings
  static const String bookings = '/bookings';
  static String booking(String id) => '/bookings/$id';
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static String confirmBooking(String id) => '/bookings/$id/confirm';

  // Notifications
  static const String notifications = '/notifications';
  static String notification(String id) => '/notifications/$id';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static const String registerDeviceToken = '/notifications/device-tokens';
  static String unregisterDeviceToken(String token) =>
      '/notifications/device-tokens/$token';
  static const String notificationPreferences = '/notifications/preferences';

  // Tickets
  static const String myTickets = '/tickets';
  static String ticketById(String id) => '/tickets/$id';
  static String checkInTicket(String ticketId) => '/tickets/$ticketId/check-in';
  static String requestRefund(String ticketId) => '/tickets/$ticketId/refund';

  // Media
  static const String uploadMedia = '/media/upload';
  static String deleteMedia(String id) => '/media/$id';

  // Search
  static const String search = '/search';
  static const String searchCreators = '/search/creators';
  static const String searchEvents = '/search/events';
}
