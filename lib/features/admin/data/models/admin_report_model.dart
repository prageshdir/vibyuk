import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';

class AdminReportModel extends AdminReport {
  const AdminReportModel({
    required super.id,
    required super.category,
    required super.targetType,
    required super.targetId,
    required super.status,
    required super.reportedByUserId,
    required super.reportedByUserName,
    required super.targetUserId,
    required super.targetUserName,
    super.targetUserAvatarUrl,
    required super.description,
    required super.evidenceUrls,
    super.reviewedByModeratorId,
    super.reviewedByModeratorName,
    super.actionTaken,
    super.actionNote,
    required super.similarReportsCount,
    required super.isRepeatOffender,
    required super.submittedAt,
    super.reviewedAt,
  });

  factory AdminReportModel.fromJson(Map<String, dynamic> json) {
    return AdminReportModel(
      id: json['id'] as String,
      category: ReportCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ReportCategory.other,
      ),
      targetType: ReportTargetType.values.firstWhere(
        (e) => e.name == json['target_type'],
        orElse: () => ReportTargetType.user,
      ),
      targetId: json['target_id'] as String,
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      reportedByUserId: json['reported_by_user_id'] as String,
      reportedByUserName: json['reported_by_user_name'] as String,
      targetUserId: json['target_user_id'] as String,
      targetUserName: json['target_user_name'] as String,
      targetUserAvatarUrl: json['target_user_avatar_url'] as String?,
      description: json['description'] as String,
      evidenceUrls: List<String>.from(json['evidence_urls'] as List? ?? []),
      reviewedByModeratorId: json['reviewed_by_moderator_id'] as String?,
      reviewedByModeratorName: json['reviewed_by_moderator_name'] as String?,
      actionTaken: json['action_taken'] != null
          ? ReportActionType.values.firstWhere(
              (e) => e.name == json['action_taken'],
              orElse: () => ReportActionType.dismiss,
            )
          : null,
      actionNote: json['action_note'] as String?,
      similarReportsCount: json['similar_reports_count'] as int? ?? 0,
      isRepeatOffender: json['is_repeat_offender'] as bool? ?? false,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'target_type': targetType.name,
        'target_id': targetId,
        'status': status.name,
        'reported_by_user_id': reportedByUserId,
        'reported_by_user_name': reportedByUserName,
        'target_user_id': targetUserId,
        'target_user_name': targetUserName,
        'target_user_avatar_url': targetUserAvatarUrl,
        'description': description,
        'evidence_urls': evidenceUrls,
        'reviewed_by_moderator_id': reviewedByModeratorId,
        'reviewed_by_moderator_name': reviewedByModeratorName,
        'action_taken': actionTaken?.name,
        'action_note': actionNote,
        'similar_reports_count': similarReportsCount,
        'is_repeat_offender': isRepeatOffender,
        'submitted_at': submittedAt.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
      };
}
