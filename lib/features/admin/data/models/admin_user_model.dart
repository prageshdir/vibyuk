import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';

class AdminUserActivityModel extends AdminUserActivity {
  const AdminUserActivityModel({
    required super.totalBookings,
    required super.completedBookings,
    required super.cancelledBookings,
    required super.totalSpent,
    required super.totalEarned,
    required super.averageRating,
    required super.reviewCount,
    required super.reportCount,
    required super.lastLoginAt,
    required super.joinedAt,
  });

  factory AdminUserActivityModel.fromJson(Map<String, dynamic> json) {
    return AdminUserActivityModel(
      totalBookings: json['total_bookings'] as int? ?? 0,
      completedBookings: json['completed_bookings'] as int? ?? 0,
      cancelledBookings: json['cancelled_bookings'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      totalEarned: (json['total_earned'] as num?)?.toDouble() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      reportCount: json['report_count'] as int? ?? 0,
      lastLoginAt: DateTime.parse(json['last_login_at'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_bookings': totalBookings,
        'completed_bookings': completedBookings,
        'cancelled_bookings': cancelledBookings,
        'total_spent': totalSpent,
        'total_earned': totalEarned,
        'average_rating': averageRating,
        'review_count': reviewCount,
        'report_count': reportCount,
        'last_login_at': lastLoginAt.toIso8601String(),
        'joined_at': joinedAt.toIso8601String(),
      };
}

class AdminModerationNoteModel extends AdminModerationNote {
  const AdminModerationNoteModel({
    required super.id,
    required super.moderatorId,
    required super.moderatorName,
    required super.content,
    required super.action,
    required super.createdAt,
  });

  factory AdminModerationNoteModel.fromJson(Map<String, dynamic> json) {
    return AdminModerationNoteModel(
      id: json['id'] as String,
      moderatorId: json['moderator_id'] as String,
      moderatorName: json['moderator_name'] as String,
      content: json['content'] as String,
      action: ModerationAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => ModerationAction.warn,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moderator_id': moderatorId,
        'moderator_name': moderatorName,
        'content': content,
        'action': action.name,
        'created_at': createdAt.toIso8601String(),
      };
}

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.displayName,
    required super.email,
    super.avatarUrl,
    required super.role,
    required super.status,
    required super.trustScore,
    required super.flagCount,
    required super.activity,
    required super.moderationHistory,
    super.suspendedUntil,
    super.banReason,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: AdminUserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => AdminUserRole.client,
      ),
      status: AdminUserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AdminUserStatus.active,
      ),
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 100,
      flagCount: json['flag_count'] as int? ?? 0,
      activity: AdminUserActivityModel.fromJson(
        json['activity'] as Map<String, dynamic>,
      ),
      moderationHistory: (json['moderation_history'] as List<dynamic>?)
              ?.map((e) => AdminModerationNoteModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      suspendedUntil: json['suspended_until'] != null
          ? DateTime.parse(json['suspended_until'] as String)
          : null,
      banReason: json['ban_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'email': email,
        'avatar_url': avatarUrl,
        'role': role.name,
        'status': status.name,
        'trust_score': trustScore,
        'flag_count': flagCount,
        'activity': (activity as AdminUserActivityModel).toJson(),
        'moderation_history': moderationHistory
            .map((e) => (e as AdminModerationNoteModel).toJson())
            .toList(),
        'suspended_until': suspendedUntil?.toIso8601String(),
        'ban_reason': banReason,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
