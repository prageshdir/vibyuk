import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/admin/data/models/admin_dispute_model.dart';
import 'package:vibyuk/features/admin/data/models/admin_platform_analytics_model.dart';
import 'package:vibyuk/features/admin/data/models/admin_report_model.dart';
import 'package:vibyuk/features/admin/data/models/admin_user_model.dart';
import 'package:vibyuk/features/admin/data/models/admin_verification_model.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_platform_analytics.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';

abstract interface class AdminRemoteDataSource {
  Future<PaginatedResponse<AdminUserModel>> getUsers({
    required int page,
    AdminUserStatus? statusFilter,
    AdminUserRole? roleFilter,
    String? searchQuery,
  });

  Future<AdminUserModel> getUserDetail({required String userId});

  Future<AdminUserModel> moderateUser({
    required String userId,
    required ModerationAction action,
    String? reason,
    Duration? suspensionDuration,
    String? note,
  });

  Future<PaginatedResponse<AdminDisputeModel>> getDisputes({
    required int page,
    DisputeStatus? statusFilter,
    DisputeType? typeFilter,
    String? searchQuery,
  });

  Future<AdminDisputeModel> getDisputeDetail({required String disputeId});

  Future<AdminDisputeModel> assignDispute({
    required String disputeId,
    required String moderatorId,
  });

  Future<AdminDisputeModel> resolveDispute({
    required String disputeId,
    required DisputeResolution resolution,
    required String note,
    double? refundAmount,
  });

  Future<AdminDisputeModel> addDisputeMessage({
    required String disputeId,
    required String content,
  });

  Future<PaginatedResponse<AdminVerificationModel>> getVerifications({
    required int page,
    VerificationStatus? statusFilter,
    VerificationType? typeFilter,
  });

  Future<AdminVerificationModel> getVerificationDetail({
    required String verificationId,
  });

  Future<AdminVerificationModel> reviewVerification({
    required String verificationId,
    required VerificationStatus decision,
    String? note,
    String? rejectionReason,
  });

  Future<AdminPlatformAnalyticsModel> getPlatformAnalytics({
    required AdminAnalyticsPeriod period,
  });

  Future<PaginatedResponse<AdminReportModel>> getReports({
    required int page,
    ReportStatus? statusFilter,
    ReportCategory? categoryFilter,
    String? searchQuery,
  });

  Future<AdminReportModel> getReportDetail({required String reportId});

  Future<AdminReportModel> handleReport({
    required String reportId,
    required ReportActionType action,
    String? note,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio _dio;

  const AdminRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedResponse<AdminUserModel>> getUsers({
    required int page,
    AdminUserStatus? statusFilter,
    AdminUserRole? roleFilter,
    String? searchQuery,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminUsers,
      queryParameters: {
        'page': page,
        if (statusFilter != null) 'status': statusFilter.name,
        if (roleFilter != null) 'role': roleFilter.name,
        if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
      },
    );
    return PaginatedResponse.fromApiResponse(
      response.data as Map<String, dynamic>,
      (json) => AdminUserModel.fromJson(json),
    );
  }

  @override
  Future<AdminUserModel> getUserDetail({required String userId}) async {
    final response = await _dio.get(ApiEndpoints.adminUser(userId));
    return AdminUserModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AdminUserModel> moderateUser({
    required String userId,
    required ModerationAction action,
    String? reason,
    Duration? suspensionDuration,
    String? note,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminUserModerate(userId),
      data: {
        'action': action.name,
        if (reason != null) 'reason': reason,
        if (suspensionDuration != null)
          'suspension_hours': suspensionDuration.inHours,
        if (note != null) 'note': note,
      },
    );
    return AdminUserModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<PaginatedResponse<AdminDisputeModel>> getDisputes({
    required int page,
    DisputeStatus? statusFilter,
    DisputeType? typeFilter,
    String? searchQuery,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminDisputes,
      queryParameters: {
        'page': page,
        if (statusFilter != null) 'status': statusFilter.name,
        if (typeFilter != null) 'type': typeFilter.name,
        if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
      },
    );
    return PaginatedResponse.fromApiResponse(
      response.data as Map<String, dynamic>,
      (json) => AdminDisputeModel.fromJson(json),
    );
  }

  @override
  Future<AdminDisputeModel> getDisputeDetail({
    required String disputeId,
  }) async {
    final response = await _dio.get(ApiEndpoints.adminDispute(disputeId));
    return AdminDisputeModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AdminDisputeModel> assignDispute({
    required String disputeId,
    required String moderatorId,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.adminDisputeAssign(disputeId),
      data: {'moderator_id': moderatorId},
    );
    return AdminDisputeModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AdminDisputeModel> resolveDispute({
    required String disputeId,
    required DisputeResolution resolution,
    required String note,
    double? refundAmount,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminDisputeResolve(disputeId),
      data: {
        'resolution': resolution.name,
        'note': note,
        if (refundAmount != null) 'refund_amount': refundAmount,
      },
    );
    return AdminDisputeModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AdminDisputeModel> addDisputeMessage({
    required String disputeId,
    required String content,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminDisputeMessages(disputeId),
      data: {'content': content},
    );
    return AdminDisputeModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<PaginatedResponse<AdminVerificationModel>> getVerifications({
    required int page,
    VerificationStatus? statusFilter,
    VerificationType? typeFilter,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminVerifications,
      queryParameters: {
        'page': page,
        if (statusFilter != null) 'status': statusFilter.name,
        if (typeFilter != null) 'type': typeFilter.name,
      },
    );
    return PaginatedResponse.fromApiResponse(
      response.data as Map<String, dynamic>,
      (json) => AdminVerificationModel.fromJson(json),
    );
  }

  @override
  Future<AdminVerificationModel> getVerificationDetail({
    required String verificationId,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminVerification(verificationId),
    );
    return AdminVerificationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AdminVerificationModel> reviewVerification({
    required String verificationId,
    required VerificationStatus decision,
    String? note,
    String? rejectionReason,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminVerificationReview(verificationId),
      data: {
        'decision': decision.name,
        if (note != null) 'note': note,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );
    return AdminVerificationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AdminPlatformAnalyticsModel> getPlatformAnalytics({
    required AdminAnalyticsPeriod period,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminAnalytics,
      queryParameters: {'period': period.name},
    );
    return AdminPlatformAnalyticsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<PaginatedResponse<AdminReportModel>> getReports({
    required int page,
    ReportStatus? statusFilter,
    ReportCategory? categoryFilter,
    String? searchQuery,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminReports,
      queryParameters: {
        'page': page,
        if (statusFilter != null) 'status': statusFilter.name,
        if (categoryFilter != null) 'category': categoryFilter.name,
        if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
      },
    );
    return PaginatedResponse.fromApiResponse(
      response.data as Map<String, dynamic>,
      (json) => AdminReportModel.fromJson(json),
    );
  }

  @override
  Future<AdminReportModel> getReportDetail({required String reportId}) async {
    final response = await _dio.get(ApiEndpoints.adminReport(reportId));
    return AdminReportModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AdminReportModel> handleReport({
    required String reportId,
    required ReportActionType action,
    String? note,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminReportHandle(reportId),
      data: {
        'action': action.name,
        if (note != null) 'note': note,
      },
    );
    return AdminReportModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
