import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_dispute_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_negotiation_message_entity.dart';

abstract interface class BookingEngineRemoteDataSource {
  Future<Map<String, dynamic>> getBookings(
      {String? status, int page = 1, int pageSize = 20});

  Future<Map<String, dynamic>> getBookingDetail(String bookingId);

  Future<Map<String, dynamic>> confirmBooking(String bookingId);

  Future<Map<String, dynamic>> cancelBooking(
      String bookingId, String reason);

  Future<Map<String, dynamic>> getBookingHistory(
      {int page = 1, int pageSize = 20});

  Future<List<Map<String, dynamic>>> getMilestones(String bookingId);

  Future<Map<String, dynamic>> submitMilestone({
    required String bookingId,
    required String milestoneId,
    required String deliverableUrl,
    String? notes,
  });

  Future<Map<String, dynamic>> approveMilestone(
      {required String bookingId, required String milestoneId});

  Future<Map<String, dynamic>> rejectMilestone(
      {required String bookingId,
      required String milestoneId,
      required String reason});

  Future<Map<String, dynamic>> getContract(String bookingId);

  Future<Map<String, dynamic>> signContract(String bookingId);

  Future<List<Map<String, dynamic>>> getNegotiationMessages(String bookingId);

  Future<Map<String, dynamic>> sendNegotiationMessage({
    required String bookingId,
    required NegotiationMessageType type,
    String? message,
    double? offeredPrice,
    String? currency,
  });

  Future<List<Map<String, dynamic>>> getTimeline(String bookingId);

  Future<Map<String, dynamic>?> getDispute(String bookingId);

  Future<Map<String, dynamic>> openDispute({
    required String bookingId,
    required DisputeReason reason,
    required String description,
  });

  Future<Map<String, dynamic>> respondToDispute({
    required String disputeId,
    required String response,
  });

  Future<Map<String, dynamic>> requestReschedule({
    required String bookingId,
    required DateTime newDate,
    String? reason,
  });

  Future<Map<String, dynamic>> respondToReschedule({
    required String rescheduleId,
    required bool accept,
    String? declineReason,
  });

  Future<Map<String, dynamic>> getInvoice(String bookingId);
}

class BookingEngineRemoteDataSourceImpl
    implements BookingEngineRemoteDataSource {
  BookingEngineRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<Map<String, dynamic>> getBookings(
      {String? status, int page = 1, int pageSize = 20}) async {
    final res = await _dio.get(
      ApiEndpoints.bookingEngineBookings,
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'per_page': pageSize,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getBookingDetail(String bookingId) async {
    final res =
        await _dio.get(ApiEndpoints.bookingEngineBooking(bookingId));
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> confirmBooking(String bookingId) async {
    final res = await _dio
        .post(ApiEndpoints.bookingEngineConfirm(bookingId));
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> cancelBooking(
      String bookingId, String reason) async {
    final res = await _dio.post(
      ApiEndpoints.bookingEngineCancel(bookingId),
      data: {'reason': reason},
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getBookingHistory(
      {int page = 1, int pageSize = 20}) async {
    final res = await _dio.get(
      ApiEndpoints.bookingEngineHistory,
      queryParameters: {'page': page, 'per_page': pageSize},
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getMilestones(String bookingId) async {
    final res =
        await _dio.get(ApiEndpoints.bookingEngineMilestones(bookingId));
    return (res.data as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> submitMilestone({
    required String bookingId,
    required String milestoneId,
    required String deliverableUrl,
    String? notes,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.bookingEngineMilestoneSubmit(bookingId, milestoneId),
      data: {
        'deliverable_url': deliverableUrl,
        if (notes != null) 'notes': notes,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> approveMilestone(
      {required String bookingId, required String milestoneId}) async {
    final res = await _dio.post(
        ApiEndpoints.bookingEngineMilestoneApprove(bookingId, milestoneId));
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> rejectMilestone(
      {required String bookingId,
      required String milestoneId,
      required String reason}) async {
    final res = await _dio.post(
      ApiEndpoints.bookingEngineMilestoneReject(bookingId, milestoneId),
      data: {'reason': reason},
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getContract(String bookingId) async {
    final res =
        await _dio.get(ApiEndpoints.bookingEngineContract(bookingId));
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> signContract(String bookingId) async {
    final res = await _dio
        .post(ApiEndpoints.bookingEngineContractSign(bookingId));
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getNegotiationMessages(
      String bookingId) async {
    final res =
        await _dio.get(ApiEndpoints.bookingEngineNegotiation(bookingId));
    return (res.data as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> sendNegotiationMessage({
    required String bookingId,
    required NegotiationMessageType type,
    String? message,
    double? offeredPrice,
    String? currency,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.bookingEngineNegotiation(bookingId),
      data: {
        'type': type.name,
        if (message != null) 'message': message,
        if (offeredPrice != null) 'offered_price': offeredPrice,
        if (currency != null) 'currency': currency,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getTimeline(String bookingId) async {
    final res =
        await _dio.get(ApiEndpoints.bookingEngineTimeline(bookingId));
    return (res.data as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> getDispute(String bookingId) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.bookingEngineDispute(bookingId));
      return res.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> openDispute({
    required String bookingId,
    required DisputeReason reason,
    required String description,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.bookingEngineDispute(bookingId),
      data: {'reason': reason.name, 'description': description},
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> respondToDispute({
    required String disputeId,
    required String response,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.bookingEngineDisputeRespond(disputeId),
      data: {'response': response},
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> requestReschedule({
    required String bookingId,
    required DateTime newDate,
    String? reason,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.bookingEngineReschedule(bookingId),
      data: {
        'new_date': newDate.toIso8601String(),
        if (reason != null) 'reason': reason,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> respondToReschedule({
    required String rescheduleId,
    required bool accept,
    String? declineReason,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.bookingEngineRescheduleRespond(rescheduleId),
      data: {
        'accept': accept,
        if (declineReason != null) 'decline_reason': declineReason,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getInvoice(String bookingId) async {
    final res =
        await _dio.get(ApiEndpoints.bookingEngineInvoice(bookingId));
    return res.data as Map<String, dynamic>;
  }
}
