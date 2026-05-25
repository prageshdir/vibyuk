import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';

class DisputePartyModel extends DisputeParty {
  const DisputePartyModel({
    required super.userId,
    required super.displayName,
    super.avatarUrl,
    required super.role,
  });

  factory DisputePartyModel.fromJson(Map<String, dynamic> json) {
    return DisputePartyModel(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'role': role,
      };
}

class DisputeEvidenceItemModel extends DisputeEvidenceItem {
  const DisputeEvidenceItemModel({
    required super.id,
    required super.submittedByUserId,
    required super.type,
    required super.url,
    super.description,
    required super.submittedAt,
  });

  factory DisputeEvidenceItemModel.fromJson(Map<String, dynamic> json) {
    return DisputeEvidenceItemModel(
      id: json['id'] as String,
      submittedByUserId: json['submitted_by_user_id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'submitted_by_user_id': submittedByUserId,
        'type': type,
        'url': url,
        'description': description,
        'submitted_at': submittedAt.toIso8601String(),
      };
}

class DisputeMessageModel extends DisputeMessage {
  const DisputeMessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.content,
    required super.isInternal,
    required super.sentAt,
  });

  factory DisputeMessageModel.fromJson(Map<String, dynamic> json) {
    return DisputeMessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      senderRole: json['sender_role'] as String,
      content: json['content'] as String,
      isInternal: json['is_internal'] as bool? ?? false,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_role': senderRole,
        'content': content,
        'is_internal': isInternal,
        'sent_at': sentAt.toIso8601String(),
      };
}

class AdminDisputeModel extends AdminDispute {
  const AdminDisputeModel({
    required super.id,
    required super.type,
    required super.status,
    required super.bookingId,
    required super.complainant,
    required super.respondent,
    required super.subject,
    required super.description,
    required super.evidence,
    required super.messages,
    super.assignedModeratorId,
    super.assignedModeratorName,
    super.resolution,
    super.resolutionNote,
    super.refundAmount,
    required super.openedAt,
    super.resolvedAt,
  });

  factory AdminDisputeModel.fromJson(Map<String, dynamic> json) {
    return AdminDisputeModel(
      id: json['id'] as String,
      type: DisputeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DisputeType.other,
      ),
      status: DisputeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DisputeStatus.open,
      ),
      bookingId: json['booking_id'] as String,
      complainant: DisputePartyModel.fromJson(
        json['complainant'] as Map<String, dynamic>,
      ),
      respondent: DisputePartyModel.fromJson(
        json['respondent'] as Map<String, dynamic>,
      ),
      subject: json['subject'] as String,
      description: json['description'] as String,
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => DisputeEvidenceItemModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => DisputeMessageModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      assignedModeratorId: json['assigned_moderator_id'] as String?,
      assignedModeratorName: json['assigned_moderator_name'] as String?,
      resolution: json['resolution'] != null
          ? DisputeResolution.values.firstWhere(
              (e) => e.name == json['resolution'],
              orElse: () => DisputeResolution.dismissed,
            )
          : null,
      resolutionNote: json['resolution_note'] as String?,
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      openedAt: DateTime.parse(json['opened_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'status': status.name,
        'booking_id': bookingId,
        'complainant': (complainant as DisputePartyModel).toJson(),
        'respondent': (respondent as DisputePartyModel).toJson(),
        'subject': subject,
        'description': description,
        'evidence': evidence
            .map((e) => (e as DisputeEvidenceItemModel).toJson())
            .toList(),
        'messages': messages
            .map((e) => (e as DisputeMessageModel).toJson())
            .toList(),
        'assigned_moderator_id': assignedModeratorId,
        'assigned_moderator_name': assignedModeratorName,
        'resolution': resolution?.name,
        'resolution_note': resolutionNote,
        'refund_amount': refundAmount,
        'opened_at': openedAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };
}
