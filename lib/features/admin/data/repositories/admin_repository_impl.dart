import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_platform_analytics.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';
import 'package:vibyuk/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl extends BaseRepository implements AdminRepository {
  final AdminRemoteDataSource _remote;

  AdminRepositoryImpl(this._remote);

  // ── User Moderation ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<AdminUser>>> getUsers({
    required int page,
    AdminUserStatus? statusFilter,
    AdminUserRole? roleFilter,
    String? searchQuery,
  }) =>
      safeCall(
        () => _remote.getUsers(
          page: page,
          statusFilter: statusFilter,
          roleFilter: roleFilter,
          searchQuery: searchQuery,
        ),
        context: 'AdminRepository.getUsers',
      );

  @override
  Future<Either<Failure, AdminUser>> getUserDetail({
    required String userId,
  }) =>
      safeCall(
        () => _remote.getUserDetail(userId: userId),
        context: 'AdminRepository.getUserDetail',
      );

  @override
  Future<Either<Failure, AdminUser>> moderateUser({
    required String userId,
    required ModerationAction action,
    String? reason,
    Duration? suspensionDuration,
    String? note,
  }) =>
      safeCall(
        () => _remote.moderateUser(
          userId: userId,
          action: action,
          reason: reason,
          suspensionDuration: suspensionDuration,
          note: note,
        ),
        context: 'AdminRepository.moderateUser',
      );

  // ── Disputes ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<AdminDispute>>> getDisputes({
    required int page,
    DisputeStatus? statusFilter,
    DisputeType? typeFilter,
    String? searchQuery,
  }) =>
      safeCall(
        () => _remote.getDisputes(
          page: page,
          statusFilter: statusFilter,
          typeFilter: typeFilter,
          searchQuery: searchQuery,
        ),
        context: 'AdminRepository.getDisputes',
      );

  @override
  Future<Either<Failure, AdminDispute>> getDisputeDetail({
    required String disputeId,
  }) =>
      safeCall(
        () => _remote.getDisputeDetail(disputeId: disputeId),
        context: 'AdminRepository.getDisputeDetail',
      );

  @override
  Future<Either<Failure, AdminDispute>> assignDispute({
    required String disputeId,
    required String moderatorId,
  }) =>
      safeCall(
        () => _remote.assignDispute(
          disputeId: disputeId,
          moderatorId: moderatorId,
        ),
        context: 'AdminRepository.assignDispute',
      );

  @override
  Future<Either<Failure, AdminDispute>> resolveDispute({
    required String disputeId,
    required DisputeResolution resolution,
    required String note,
    double? refundAmount,
  }) =>
      safeCall(
        () => _remote.resolveDispute(
          disputeId: disputeId,
          resolution: resolution,
          note: note,
          refundAmount: refundAmount,
        ),
        context: 'AdminRepository.resolveDispute',
      );

  @override
  Future<Either<Failure, AdminDispute>> addDisputeMessage({
    required String disputeId,
    required String content,
  }) =>
      safeCall(
        () => _remote.addDisputeMessage(
          disputeId: disputeId,
          content: content,
        ),
        context: 'AdminRepository.addDisputeMessage',
      );

  // ── Verifications ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<AdminVerification>>>
      getVerifications({
    required int page,
    VerificationStatus? statusFilter,
    VerificationType? typeFilter,
  }) =>
          safeCall(
            () => _remote.getVerifications(
              page: page,
              statusFilter: statusFilter,
              typeFilter: typeFilter,
            ),
            context: 'AdminRepository.getVerifications',
          );

  @override
  Future<Either<Failure, AdminVerification>> getVerificationDetail({
    required String verificationId,
  }) =>
      safeCall(
        () => _remote.getVerificationDetail(verificationId: verificationId),
        context: 'AdminRepository.getVerificationDetail',
      );

  @override
  Future<Either<Failure, AdminVerification>> reviewVerification({
    required String verificationId,
    required VerificationStatus decision,
    String? note,
    String? rejectionReason,
  }) =>
      safeCall(
        () => _remote.reviewVerification(
          verificationId: verificationId,
          decision: decision,
          note: note,
          rejectionReason: rejectionReason,
        ),
        context: 'AdminRepository.reviewVerification',
      );

  // ── Platform Analytics ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AdminPlatformAnalytics>> getPlatformAnalytics({
    required AdminAnalyticsPeriod period,
  }) =>
      safeCall(
        () => _remote.getPlatformAnalytics(period: period),
        context: 'AdminRepository.getPlatformAnalytics',
      );

  // ── Reports ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<AdminReport>>> getReports({
    required int page,
    ReportStatus? statusFilter,
    ReportCategory? categoryFilter,
    String? searchQuery,
  }) =>
      safeCall(
        () => _remote.getReports(
          page: page,
          statusFilter: statusFilter,
          categoryFilter: categoryFilter,
          searchQuery: searchQuery,
        ),
        context: 'AdminRepository.getReports',
      );

  @override
  Future<Either<Failure, AdminReport>> getReportDetail({
    required String reportId,
  }) =>
      safeCall(
        () => _remote.getReportDetail(reportId: reportId),
        context: 'AdminRepository.getReportDetail',
      );

  @override
  Future<Either<Failure, AdminReport>> handleReport({
    required String reportId,
    required ReportActionType action,
    String? note,
  }) =>
      safeCall(
        () => _remote.handleReport(
          reportId: reportId,
          action: action,
          note: note,
        ),
        context: 'AdminRepository.handleReport',
      );
}
