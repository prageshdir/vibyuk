import 'package:equatable/equatable.dart';

enum AdminUserStatus { active, suspended, banned, pendingVerification, deactivated }
enum AdminUserRole { client, creator, both, admin }
enum ModerationAction { warn, suspend, ban, unban, resetPassword, deleteAccount }

class AdminUserActivity extends Equatable {
  final int totalBookings;
  final int totalDisputes;
  final int totalReports;
  final double totalSpend;
  final double totalEarned;
  final DateTime? lastLoginAt;

  const AdminUserActivity({
    required this.totalBookings,
    required this.totalDisputes,
    required this.totalReports,
    required this.totalSpend,
    required this.totalEarned,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
        totalBookings,
        totalDisputes,
        totalReports,
        totalSpend,
        totalEarned,
        lastLoginAt,
      ];
}

class AdminModerationNote extends Equatable {
  final String id;
  final String note;
  final String moderatorId;
  final String moderatorName;
  final ModerationAction action;
  final DateTime createdAt;

  const AdminModerationNote({
    required this.id,
    required this.note,
    required this.moderatorId,
    required this.moderatorName,
    required this.action,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, note, moderatorId, moderatorName, action, createdAt];
}

class AdminUser extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final AdminUserRole role;
  final AdminUserStatus status;
  final String? suspensionReason;
  final DateTime? suspendedUntil;
  final String? banReason;
  final bool isEmailVerified;
  final bool isIdVerified;
  final double trustScore;
  final int flagCount;
  final AdminUserActivity activity;
  final List<AdminModerationNote> moderationHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.status,
    this.suspensionReason,
    this.suspendedUntil,
    this.banReason,
    required this.isEmailVerified,
    required this.isIdVerified,
    required this.trustScore,
    required this.flagCount,
    required this.activity,
    required this.moderationHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSuspended => status == AdminUserStatus.suspended;
  bool get isBanned => status == AdminUserStatus.banned;
  bool get isActive => status == AdminUserStatus.active;
  bool get isHighRisk => flagCount >= 3 || trustScore < 40;

  AdminUser copyWith({
    AdminUserStatus? status,
    String? suspensionReason,
    DateTime? suspendedUntil,
    String? banReason,
    int? flagCount,
    List<AdminModerationNote>? moderationHistory,
  }) {
    return AdminUser(
      id: id,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      role: role,
      status: status ?? this.status,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      banReason: banReason ?? this.banReason,
      isEmailVerified: isEmailVerified,
      isIdVerified: isIdVerified,
      trustScore: trustScore,
      flagCount: flagCount ?? this.flagCount,
      activity: activity,
      moderationHistory: moderationHistory ?? this.moderationHistory,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id, email, fullName, avatarUrl, role, status, suspensionReason,
        suspendedUntil, banReason, isEmailVerified, isIdVerified,
        trustScore, flagCount, activity, moderationHistory, createdAt, updatedAt,
      ];
}
