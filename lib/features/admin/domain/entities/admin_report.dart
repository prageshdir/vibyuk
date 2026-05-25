import 'package:equatable/equatable.dart';

enum ReportStatus { pending, underReview, actionTaken, dismissed, escalated }
enum ReportCategory {
  inappropriateContent,
  fraud,
  harassment,
  spam,
  fakeProfile,
  copyright,
  other,
}
enum ReportTargetType { user, booking, review, message, portfolio }
enum ReportActionType { dismiss, warnUser, removeContent, suspendUser, banUser, escalate }

class AdminReport extends Equatable {
  final String id;
  final ReportCategory category;
  final ReportTargetType targetType;
  final String targetId;
  final ReportStatus status;
  final String reportedByUserId;
  final String reportedByUserName;
  final String targetUserId;
  final String targetUserName;
  final String? targetUserAvatarUrl;
  final String description;
  final List<String> evidenceUrls;
  final String? reviewedByModeratorId;
  final String? reviewedByModeratorName;
  final ReportActionType? actionTaken;
  final String? actionNote;
  final int similarReportsCount;
  final bool isRepeatOffender;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const AdminReport({
    required this.id,
    required this.category,
    required this.targetType,
    required this.targetId,
    required this.status,
    required this.reportedByUserId,
    required this.reportedByUserName,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserAvatarUrl,
    required this.description,
    required this.evidenceUrls,
    this.reviewedByModeratorId,
    this.reviewedByModeratorName,
    this.actionTaken,
    this.actionNote,
    required this.similarReportsCount,
    required this.isRepeatOffender,
    required this.submittedAt,
    this.reviewedAt,
  });

  bool get isPending => status == ReportStatus.pending;
  bool get requiresUrgentReview =>
      isRepeatOffender || similarReportsCount >= 3 ||
      category == ReportCategory.fraud || category == ReportCategory.harassment;
  int get daysPending => DateTime.now().difference(submittedAt).inDays;

  AdminReport copyWith({
    ReportStatus? status,
    String? reviewedByModeratorId,
    String? reviewedByModeratorName,
    ReportActionType? actionTaken,
    String? actionNote,
    DateTime? reviewedAt,
  }) {
    return AdminReport(
      id: id, category: category, targetType: targetType, targetId: targetId,
      status: status ?? this.status, reportedByUserId: reportedByUserId,
      reportedByUserName: reportedByUserName, targetUserId: targetUserId,
      targetUserName: targetUserName, targetUserAvatarUrl: targetUserAvatarUrl,
      description: description, evidenceUrls: evidenceUrls,
      reviewedByModeratorId: reviewedByModeratorId ?? this.reviewedByModeratorId,
      reviewedByModeratorName: reviewedByModeratorName ?? this.reviewedByModeratorName,
      actionTaken: actionTaken ?? this.actionTaken,
      actionNote: actionNote ?? this.actionNote,
      similarReportsCount: similarReportsCount,
      isRepeatOffender: isRepeatOffender,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, category, targetType, targetId, status, reportedByUserId,
        reportedByUserName, targetUserId, targetUserName, targetUserAvatarUrl,
        description, evidenceUrls, reviewedByModeratorId, reviewedByModeratorName,
        actionTaken, actionNote, similarReportsCount, isRepeatOffender,
        submittedAt, reviewedAt,
      ];
}
