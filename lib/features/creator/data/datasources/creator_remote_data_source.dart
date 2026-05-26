import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';

abstract interface class CreatorRemoteDataSource {
  // Profile
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> getPublicProfile(String creatorId);
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body);
  Future<Map<String, dynamic>> uploadProfileImage(String filePath);
  Future<Map<String, dynamic>> uploadCoverImage(String filePath);
  Future<Map<String, dynamic>> completeOnboardingStep(String step);

  // Portfolio
  Future<Map<String, dynamic>> getPortfolio(int page, int pageSize);
  Future<Map<String, dynamic>> addPortfolioItem(FormData formData);
  Future<Map<String, dynamic>> updatePortfolioItem(
      String itemId, Map<String, dynamic> body);
  Future<void> deletePortfolioItem(String itemId);
  Future<void> reorderPortfolio(List<String> orderedIds);

  // Pricing
  Future<List<dynamic>> getPricingPackages();
  Future<Map<String, dynamic>> createPricingPackage(Map<String, dynamic> body);
  Future<Map<String, dynamic>> updatePricingPackage(
      String packageId, Map<String, dynamic> body);
  Future<void> deletePricingPackage(String packageId);

  // Availability
  Future<Map<String, dynamic>> getAvailability();
  Future<Map<String, dynamic>> updateDayAvailability(
      Map<String, dynamic> body);
  Future<Map<String, dynamic>> updateWeeklySlots(List<dynamic> slots);
  Future<Map<String, dynamic>> blockDates(List<String> dates);

  // Analytics
  Future<Map<String, dynamic>> getAnalytics(String period);

  // Earnings
  Future<Map<String, dynamic>> getEarnings(String period);
  Future<Map<String, dynamic>> requestPayout(double amount);

  // Booking Requests
  Future<Map<String, dynamic>> getBookingRequests(
      int page, int pageSize, String? status);
  Future<Map<String, dynamic>> getBookingRequestDetail(String requestId);
  Future<Map<String, dynamic>> respondToBookingRequest(
      String requestId, Map<String, dynamic> body);

  // Applications
  Future<Map<String, dynamic>> getApplications(
      int page, int pageSize, String? status);
  Future<Map<String, dynamic>> applyToCampaign(
      String campaignId, Map<String, dynamic> body);
  Future<void> withdrawApplication(String applicationId);

  // Reviews
  Future<Map<String, dynamic>> getReviews(int page, int pageSize);
  Future<Map<String, dynamic>> respondToReview({
    required String reviewId,
    required String response,
  });

  // KYC
  Future<Map<String, dynamic>> getKycStatus();
  Future<Map<String, dynamic>> submitKyc(FormData formData);
}

class CreatorRemoteDataSourceImpl implements CreatorRemoteDataSource {
  CreatorRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response r) {
    final body = r.data as Map<String, dynamic>;
    if (body['data'] is Map<String, dynamic>) return body['data'] as Map<String, dynamic>;
    return body;
  }

  List<dynamic> _dataList(Response r) {
    final body = r.data as Map<String, dynamic>;
    if (body['data'] is List) return body['data'] as List<dynamic>;
    if (r.data is List) return r.data as List<dynamic>;
    return [];
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final r = await _dio.get(ApiEndpoints.creatorMe);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getPublicProfile(String creatorId) async {
    final r = await _dio.get(ApiEndpoints.creatorPublicProfile(creatorId));
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final r = await _dio.patch(ApiEndpoints.creatorMe, data: body);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> uploadProfileImage(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final r = await _dio.post(ApiEndpoints.creatorMeProfileImage, data: form);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> uploadCoverImage(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final r = await _dio.post(ApiEndpoints.creatorMeCoverImage, data: form);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> completeOnboardingStep(String step) async {
    final r = await _dio.post(ApiEndpoints.creatorMeOnboarding, data: {'step': step});
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getPortfolio(int page, int pageSize) async {
    final r = await _dio.get(ApiEndpoints.creatorPortfolioItems,
        queryParameters: {'page': page, 'page_size': pageSize});
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> addPortfolioItem(FormData formData) async {
    final r = await _dio.post(ApiEndpoints.creatorPortfolioItems, data: formData);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> updatePortfolioItem(
      String itemId, Map<String, dynamic> body) async {
    final r = await _dio.patch(ApiEndpoints.creatorPortfolioItem(itemId), data: body);
    return _data(r);
  }

  @override
  Future<void> deletePortfolioItem(String itemId) async {
    await _dio.delete(ApiEndpoints.creatorPortfolioItem(itemId));
  }

  @override
  Future<void> reorderPortfolio(List<String> orderedIds) async {
    await _dio.post(ApiEndpoints.creatorPortfolioReorder,
        data: {'ordered_ids': orderedIds});
  }

  @override
  Future<List<dynamic>> getPricingPackages() async {
    final r = await _dio.get(ApiEndpoints.creatorPricingPackages);
    return _dataList(r);
  }

  @override
  Future<Map<String, dynamic>> createPricingPackage(
      Map<String, dynamic> body) async {
    final r = await _dio.post(ApiEndpoints.creatorPricingPackages, data: body);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> updatePricingPackage(
      String packageId, Map<String, dynamic> body) async {
    final r = await _dio.patch(ApiEndpoints.creatorPricingPackage(packageId), data: body);
    return _data(r);
  }

  @override
  Future<void> deletePricingPackage(String packageId) async {
    await _dio.delete(ApiEndpoints.creatorPricingPackage(packageId));
  }

  @override
  Future<Map<String, dynamic>> getAvailability() async {
    final r = await _dio.get(ApiEndpoints.creatorAvailability);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> updateDayAvailability(
      Map<String, dynamic> body) async {
    final r = await _dio.patch(ApiEndpoints.creatorAvailabilityDays, data: body);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> updateWeeklySlots(List<dynamic> slots) async {
    final r = await _dio.put(ApiEndpoints.creatorAvailabilitySlots,
        data: {'slots': slots});
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> blockDates(List<String> dates) async {
    final r = await _dio.post(ApiEndpoints.creatorAvailabilityBlock,
        data: {'dates': dates});
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getAnalytics(String period) async {
    final r = await _dio.get(ApiEndpoints.creatorAnalytics,
        queryParameters: {'period': period});
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getEarnings(String period) async {
    final r = await _dio.get(ApiEndpoints.creatorEarnings,
        queryParameters: {'period': period});
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> requestPayout(double amount) async {
    final r = await _dio.post(ApiEndpoints.creatorPayoutRequest,
        data: {'amount': amount});
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getBookingRequests(
      int page, int pageSize, String? status) async {
    final r = await _dio.get(ApiEndpoints.creatorBookingRequests,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (status != null) 'status': status,
        });
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getBookingRequestDetail(String requestId) async {
    final r = await _dio.get(ApiEndpoints.creatorBookingRequest(requestId));
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> respondToBookingRequest(
      String requestId, Map<String, dynamic> body) async {
    final r = await _dio.post(
        ApiEndpoints.creatorBookingRequestRespond(requestId),
        data: body);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getApplications(
      int page, int pageSize, String? status) async {
    final r = await _dio.get(ApiEndpoints.creatorApplications,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (status != null) 'status': status,
        });
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> applyToCampaign(
      String campaignId, Map<String, dynamic> body) async {
    final r = await _dio.post(ApiEndpoints.campaignApply(campaignId), data: body);
    return _data(r);
  }

  @override
  Future<void> withdrawApplication(String applicationId) async {
    await _dio.post(ApiEndpoints.creatorApplicationWithdraw(applicationId));
  }

  @override
  Future<Map<String, dynamic>> getReviews(int page, int pageSize) async {
    final r = await _dio.get(ApiEndpoints.creatorReviewsMe,
        queryParameters: {'page': page, 'page_size': pageSize});
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> respondToReview({
    required String reviewId,
    required String response,
  }) async {
    final r = await _dio.post(
      '${ApiEndpoints.creatorReviewsMe}/$reviewId/respond',
      data: {'response': response},
    );
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getKycStatus() async {
    final r = await _dio.get(ApiEndpoints.creatorKyc);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> submitKyc(FormData formData) async {
    final r = await _dio.post(ApiEndpoints.creatorKyc, data: formData);
    return _data(r);
  }
}
