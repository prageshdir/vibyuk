part of 'admin_moderation_bloc.dart';

sealed class AdminModerationEvent {}

final class AdminModerationFetchUsers extends AdminModerationEvent {
  final bool refresh;
  AdminModerationFetchUsers({this.refresh = false});
}

final class AdminModerationLoadMore extends AdminModerationEvent {}

final class AdminModerationSearchChanged extends AdminModerationEvent {
  final String query;
  AdminModerationSearchChanged(this.query);
}

final class AdminModerationStatusFilterChanged extends AdminModerationEvent {
  final AdminUserStatus? status;
  AdminModerationStatusFilterChanged(this.status);
}

final class AdminModerationRoleFilterChanged extends AdminModerationEvent {
  final AdminUserRole? role;
  AdminModerationRoleFilterChanged(this.role);
}

final class AdminModerationSelectUser extends AdminModerationEvent {
  final String userId;
  AdminModerationSelectUser(this.userId);
}

final class AdminModerationModerateUser extends AdminModerationEvent {
  final String userId;
  final ModerationAction action;
  final String? reason;
  final Duration? suspensionDuration;
  final String? note;

  AdminModerationModerateUser({
    required this.userId,
    required this.action,
    this.reason,
    this.suspensionDuration,
    this.note,
  });
}
