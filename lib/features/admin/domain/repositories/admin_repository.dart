import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_platform_analytics.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';

abstract interface class AdminRepository {
  // ── User Moderation ──────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<AdminUser>>> getUsers({
    required int page,
    AdminUserStatus? statusFilter,
    AdminUserRole? roleFilter,
    String? searchQuery,
  });

  Future<Either<Failure, AdminUser>> getUserDetail({required String userId});

  Future<Either<Failure, AdminUser>> moderateUser({
    required String userId,
    required ModerationAction action,
    String? reason,
    Duration? suspensionDuration,
    String? note,
  });

  // ── Disputes ─────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<AdminDispute>>> getDisputes({
    required int page,
    DisputeStatus? statusFilter,
    DisputeType? typeFilter,
    String? searchQuery,
  });

  Future<Either<Failure, AdminDispute>> getDisputeDetail({required String disputeId});

  Future<Either<Failure, AdminDispute>> assignDispute({
    required String disputeId,
    required String moderatorId,
  });

  Future<Either<Failure, AdminDispute>> resolveDispute({
    required String disputeId,
    required DisputeResolution resolution,
    required String note,
    double? refundAmount,
  });

  Future<Either<Failure, AdminDispute>> addDisputeMessage({
    required String disputeId,
    required String content,
  });

  // ── Verifications ────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<AdminVerification>>> getVerifications({
    required int page,
    VerificationStatus? statusFilter,
    VerificationType? typeFilter,
  });

  Future<Either<Failure, AdminVerification>> getVerificationDetail({
    required String verificationId,
  });

  Future<Either<Failure, AdminVerification>> reviewVerification({
    required String verificationId,
    required VerificationStatus decision,
    String? note,
    String? rejectionReason,
  });

  // ── Platform Analytics ────────────────────────────────────────────────────
  Future<Either<Failure, AdminPlatformAnalytics>> getPlatformAnalytics({
    required AdminAnalyticsPeriod period,
  });

  // ── Reports ───────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<AdminReport>>> getReports({
    required int page,
    ReportStatus? statusFilter,
    ReportCategory? categoryFilter,
    String? searchQuery,
  });

  Future<Either<Failure, AdminReport>> getReportDetail({required String reportId});

  Future<Either<Failure, AdminReport>> handleReport({
    required String reportId,
    required ReportActionType action,
    String? note,
  });
}
