part of 'admin_moderation_bloc.dart';

enum AdminModerationStatus { initial, loading, loaded, loadingMore, error }

final class AdminModerationState extends Equatable {
  final AdminModerationStatus status;
  final List<AdminUser> users;
  final AdminUser? selectedUser;
  final AdminUserStatus? statusFilter;
  final AdminUserRole? roleFilter;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;
  final bool isModeratingUser;
  final String? errorMessage;
  final String? moderationSuccess;

  const AdminModerationState({
    this.status = AdminModerationStatus.initial,
    this.users = const [],
    this.selectedUser,
    this.statusFilter,
    this.roleFilter,
    this.searchQuery = '',
    this.currentPage = 0,
    this.hasMore = true,
    this.isModeratingUser = false,
    this.errorMessage,
    this.moderationSuccess,
  });

  AdminModerationState copyWith({
    AdminModerationStatus? status,
    List<AdminUser>? users,
    AdminUser? selectedUser,
    AdminUserStatus? Function()? statusFilter,
    AdminUserRole? Function()? roleFilter,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    bool? isModeratingUser,
    String? errorMessage,
    String? moderationSuccess,
  }) {
    return AdminModerationState(
      status: status ?? this.status,
      users: users ?? this.users,
      selectedUser: selectedUser ?? this.selectedUser,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      roleFilter: roleFilter != null ? roleFilter() : this.roleFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isModeratingUser: isModeratingUser ?? this.isModeratingUser,
      errorMessage: errorMessage,
      moderationSuccess: moderationSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status, users, selectedUser, statusFilter, roleFilter,
        searchQuery, currentPage, hasMore, isModeratingUser,
        errorMessage, moderationSuccess,
      ];
}
