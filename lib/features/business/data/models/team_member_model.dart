import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';

class TeamMemberModel {
  const TeamMemberModel({
    required this.id,
    this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.role,
    required this.inviteStatus,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String role;
  final String inviteStatus;
  final DateTime createdAt;

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) => TeamMemberModel(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        email: json['email'] as String,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        role: json['role'] as String? ?? 'member',
        inviteStatus: json['invite_status'] as String? ?? 'pending',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  TeamMemberEntity toEntity() => TeamMemberEntity(
        id: id,
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
        role: TeamRole.values.firstWhere(
          (r) => r.name == role,
          orElse: () => TeamRole.member,
        ),
        inviteStatus: InviteStatus.values.firstWhere(
          (s) => s.name == inviteStatus,
          orElse: () => InviteStatus.pending,
        ),
        createdAt: createdAt,
      );
}
