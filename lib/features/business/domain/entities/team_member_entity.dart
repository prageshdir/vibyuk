import 'package:equatable/equatable.dart';

enum TeamRole { owner, admin, member, viewer }
enum InviteStatus { pending, accepted, declined }

extension TeamRoleX on TeamRole {
  String get label => switch (this) {
        TeamRole.owner => 'Owner',
        TeamRole.admin => 'Admin',
        TeamRole.member => 'Member',
        TeamRole.viewer => 'Viewer',
      };

  bool get canManageTeam => this == TeamRole.owner || this == TeamRole.admin;
  bool get canCreateCampaigns => this != TeamRole.viewer;
  bool get canRemoveMembers => this == TeamRole.owner || this == TeamRole.admin;
}

extension InviteStatusX on InviteStatus {
  String get label => switch (this) {
        InviteStatus.pending => 'Pending',
        InviteStatus.accepted => 'Active',
        InviteStatus.declined => 'Declined',
      };
}

class TeamMemberEntity extends Equatable {
  const TeamMemberEntity({
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
  final TeamRole role;
  final InviteStatus inviteStatus;
  final DateTime createdAt;

  String get displayName {
    if (firstName != null && lastName != null) return '$firstName $lastName';
    if (firstName != null) return firstName!;
    return email;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool get isPending => inviteStatus == InviteStatus.pending;
  bool get isActive => inviteStatus == InviteStatus.accepted;

  TeamMemberEntity copyWith({TeamRole? role}) => TeamMemberEntity(
        id: id,
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
        role: role ?? this.role,
        inviteStatus: inviteStatus,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id, userId, email, firstName, lastName, avatarUrl,
        role, inviteStatus, createdAt,
      ];
}
