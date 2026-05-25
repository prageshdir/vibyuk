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

  // AI Features
  static const String aiRecommendations = '/ai/recommendations';
  static const String aiCampaigns = '/ai/campaigns';
  static const String aiCampaignGenerate = '/ai/campaigns/generate';
  static String aiCampaignStep(String campaignId, String stepId) =>
      '/ai/campaigns/$campaignId/steps/$stepId';
  static const String aiPricing = '/ai/pricing';
  static const String aiPricingSuggestions = '/ai/pricing/suggestions';
  static const String aiAnalytics = '/ai/analytics';
  static const String aiInsights = '/ai/insights';
  static String aiInsightDismiss(String id) => '/ai/insights/$id/dismiss';
  static const String aiConversations = '/ai/conversations';
  static String aiConversation(String id) => '/ai/conversations/$id';
  static String aiChatMessages(String conversationId) =>
      '/ai/conversations/$conversationId/messages';

  // Admin
  static const String adminUsers = '/admin/users';
  static String adminUser(String id) => '/admin/users/$id';
  static String adminUserModerate(String id) => '/admin/users/$id/moderate';
  static const String adminDisputes = '/admin/disputes';
  static String adminDispute(String id) => '/admin/disputes/$id';
  static String adminDisputeAssign(String id) => '/admin/disputes/$id/assign';
  static String adminDisputeResolve(String id) => '/admin/disputes/$id/resolve';
  static String adminDisputeMessages(String id) => '/admin/disputes/$id/messages';
  static const String adminVerifications = '/admin/verifications';
  static String adminVerification(String id) => '/admin/verifications/$id';
  static String adminVerificationReview(String id) =>
      '/admin/verifications/$id/review';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminReports = '/admin/reports';
  static String adminReport(String id) => '/admin/reports/$id';
  static String adminReportHandle(String id) => '/admin/reports/$id/handle';
}
