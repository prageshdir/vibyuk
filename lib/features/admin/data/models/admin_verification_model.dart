import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';

class VerificationDocumentModel extends VerificationDocument {
  const VerificationDocumentModel({
    required super.id,
    required super.type,
    required super.url,
    super.expiryDate,
    required super.uploadedAt,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentModel(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'url': url,
        'expiry_date': expiryDate?.toIso8601String(),
        'uploaded_at': uploadedAt.toIso8601String(),
      };
}

class AdminVerificationModel extends AdminVerification {
  const AdminVerificationModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.type,
    required super.status,
    required super.documents,
    super.selfieUrl,
    super.reviewerNote,
    super.rejectionReason,
    super.reviewedByModeratorId,
    super.reviewedByModeratorName,
    required super.submittedAt,
    super.reviewedAt,
  });

  factory AdminVerificationModel.fromJson(Map<String, dynamic> json) {
    return AdminVerificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      type: VerificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VerificationType.identity,
      ),
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => VerificationDocumentModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      selfieUrl: json['selfie_url'] as String?,
      reviewerNote: json['reviewer_note'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      reviewedByModeratorId: json['reviewed_by_moderator_id'] as String?,
      reviewedByModeratorName: json['reviewed_by_moderator_name'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_avatar_url': userAvatarUrl,
        'type': type.name,
        'status': status.name,
        'documents': documents
            .map((e) => (e as VerificationDocumentModel).toJson())
            .toList(),
        'selfie_url': selfieUrl,
        'reviewer_note': reviewerNote,
        'rejection_reason': rejectionReason,
        'reviewed_by_moderator_id': reviewedByModeratorId,
        'reviewed_by_moderator_name': reviewedByModeratorName,
        'submitted_at': submittedAt.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
      };
}
