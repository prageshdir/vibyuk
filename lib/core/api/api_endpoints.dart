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

  // Wedding
  static const String weddings = '/wedding/projects';
  static String weddingById(String id) => '/wedding/projects/$id';
  static String weddingAnalytics(String id) => '/wedding/projects/$id/analytics';

  // Wedding Vendors & Venues
  static const String weddingVendors = '/wedding/vendors';
  static String weddingVendorById(String id) => '/wedding/vendors/$id';
  static const String weddingVenues = '/wedding/venues';
  static String weddingVenueById(String id) => '/wedding/venues/$id';

  // Wedding Packages
  static const String weddingPackages = '/wedding/packages';
  static String weddingPackageById(String id) => '/wedding/packages/$id';
  static String buildWeddingPackage(String weddingId) =>
      '/wedding/projects/$weddingId/packages';

  // Vendor Bookings
  static String weddingBookings(String weddingId) =>
      '/wedding/projects/$weddingId/bookings';
  static String weddingBookingById(String weddingId, String bookingId) =>
      '/wedding/projects/$weddingId/bookings/$bookingId';

  // Budget
  static String weddingBudget(String weddingId) =>
      '/wedding/projects/$weddingId/budget';
  static String weddingBudgetItem(String weddingId, String itemId) =>
      '/wedding/projects/$weddingId/budget/$itemId';

  // Timeline
  static String weddingTimeline(String weddingId) =>
      '/wedding/projects/$weddingId/timeline';
  static String weddingTimelineTask(String weddingId, String taskId) =>
      '/wedding/projects/$weddingId/timeline/$taskId';

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

  // Booking Engine — Bookings
  static const String bookingEngineBookings = '/booking-engine/bookings';
  static String bookingEngineBooking(String id) =>
      '/booking-engine/bookings/$id';
  static String bookingEngineConfirm(String id) =>
      '/booking-engine/bookings/$id/confirm';
  static String bookingEngineCancel(String id) =>
      '/booking-engine/bookings/$id/cancel';
  static const String bookingEngineHistory = '/booking-engine/bookings/history';

  // Booking Engine — Milestones
  static String bookingEngineMilestones(String bookingId) =>
      '/booking-engine/bookings/$bookingId/milestones';
  static String bookingEngineMilestone(String bookingId, String milestoneId) =>
      '/booking-engine/bookings/$bookingId/milestones/$milestoneId';
  static String bookingEngineMilestoneSubmit(
          String bookingId, String milestoneId) =>
      '/booking-engine/bookings/$bookingId/milestones/$milestoneId/submit';
  static String bookingEngineMilestoneApprove(
          String bookingId, String milestoneId) =>
      '/booking-engine/bookings/$bookingId/milestones/$milestoneId/approve';
  static String bookingEngineMilestoneReject(
          String bookingId, String milestoneId) =>
      '/booking-engine/bookings/$bookingId/milestones/$milestoneId/reject';

  // Booking Engine — Contract
  static String bookingEngineContract(String bookingId) =>
      '/booking-engine/bookings/$bookingId/contract';
  static String bookingEngineContractSign(String bookingId) =>
      '/booking-engine/bookings/$bookingId/contract/sign';

  // Booking Engine — Negotiation
  static String bookingEngineNegotiation(String bookingId) =>
      '/booking-engine/bookings/$bookingId/negotiation';

  // Booking Engine — Timeline
  static String bookingEngineTimeline(String bookingId) =>
      '/booking-engine/bookings/$bookingId/timeline';

  // Booking Engine — Dispute
  static String bookingEngineDispute(String bookingId) =>
      '/booking-engine/bookings/$bookingId/dispute';
  static String bookingEngineDisputeRespond(String disputeId) =>
      '/booking-engine/disputes/$disputeId/respond';

  // Booking Engine — Reschedule
  static String bookingEngineReschedule(String bookingId) =>
      '/booking-engine/bookings/$bookingId/reschedule';
  static String bookingEngineRescheduleRespond(String rescheduleId) =>
      '/booking-engine/reschedules/$rescheduleId/respond';

  // Booking Engine — Invoice
  static String bookingEngineInvoice(String bookingId) =>
      '/booking-engine/bookings/$bookingId/invoice';

  // Chat
  static const String chatConversations = '/chat/conversations';
  static String chatMessages(String conversationId) =>
      '/chat/conversations/$conversationId/messages';
  static String chatConversationRead(String conversationId) =>
      '/chat/conversations/$conversationId/read';

  // Payments
  static const String payments = '/payments';
  static String payment(String id) => '/payments/$id';
  static const String paymentInitiate = '/payments/initiate';
  static String paymentVerify(String paymentId) =>
      '/payments/$paymentId/verify';

  // Escrow
  static String escrowByBooking(String bookingId) =>
      '/booking-engine/bookings/$bookingId/escrow';
  static String escrowRelease(String escrowId) => '/escrow/$escrowId/release';
  static String escrowRefund(String escrowId) => '/escrow/$escrowId/refund';

  // Transactions
  static const String transactions = '/transactions';

  // Invoices
  static String invoiceByBooking(String bookingId) =>
      '/booking-engine/bookings/$bookingId/invoice-gst';
  static String invoicePdf(String invoiceId) => '/invoices/$invoiceId/pdf';

  // Payment Analytics
  static const String paymentAnalytics = '/payments/analytics';

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
  // Tourism
  static const String tourismDestinations = '/tourism/destinations';
  static String tourismDestination(String id) => '/tourism/destinations/$id';
  static String destinationGallery(String id) => '/tourism/destinations/$id/gallery';
  static const String tourismCampaigns = '/tourism/campaigns';
  static String tourismCampaign(String id) => '/tourism/campaigns/$id';
  static String publishTourismCampaign(String id) => '/tourism/campaigns/$id/publish';
  static const String famTrips = '/tourism/fam-trips';
  static String famTrip(String id) => '/tourism/fam-trips/$id';
  static String applyFamTrip(String id) => '/tourism/fam-trips/$id/apply';
  static const String tourismCollaborations = '/tourism/collaborations';
  static String tourismCollaboration(String id) => '/tourism/collaborations/$id';
  static const String tourismAnalytics = '/tourism/analytics';

  // Subscriptions
  static const String subscription = '/subscriptions/me';
  static const String subscriptionOrders = '/subscriptions/orders';
  static const String subscriptionVerify = '/subscriptions/verify';
}
