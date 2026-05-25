import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_moderation_usecases.dart';

part 'admin_moderation_event.dart';
part 'admin_moderation_state.dart';

class AdminModerationBloc
    extends BaseBloc<AdminModerationEvent, AdminModerationState> {
  final GetUsersUseCase _getUsers;
  final GetUserDetailUseCase _getUserDetail;
  final ModerateUserUseCase _moderateUser;

  AdminModerationBloc({
    required GetUsersUseCase getUsers,
    required GetUserDetailUseCase getUserDetail,
    required ModerateUserUseCase moderateUser,
  })  : _getUsers = getUsers,
        _getUserDetail = getUserDetail,
        _moderateUser = moderateUser,
        super(const AdminModerationState()) {
    on<AdminModerationFetchUsers>(_onFetchUsers);
    on<AdminModerationLoadMore>(_onLoadMore);
    on<AdminModerationSearchChanged>(_onSearchChanged);
    on<AdminModerationStatusFilterChanged>(_onStatusFilterChanged);
    on<AdminModerationRoleFilterChanged>(_onRoleFilterChanged);
    on<AdminModerationSelectUser>(_onSelectUser);
    on<AdminModerationModerateUser>(_onModerateUser);
  }

  Future<void> _onFetchUsers(
    AdminModerationFetchUsers event,
    Emitter<AdminModerationState> emit,
  ) async {
    emit(state.copyWith(
      status: AdminModerationStatus.loading,
      users: event.refresh ? [] : state.users,
      currentPage: event.refresh ? 0 : state.currentPage,
    ));

    final result = await _getUsers(GetUsersParams(
      page: 1,
      statusFilter: state.statusFilter,
      roleFilter: state.roleFilter,
      searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminModerationStatus.error,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: AdminModerationStatus.loaded,
        users: page.items,
        currentPage: 1,
        hasMore: page.hasNextPage,
      )),
    );
  }

  Future<void> _onLoadMore(
    AdminModerationLoadMore event,
    Emitter<AdminModerationState> emit,
  ) async {
    if (!state.hasMore || state.status == AdminModerationStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: AdminModerationStatus.loadingMore));

    final result = await _getUsers(GetUsersParams(
      page: state.currentPage + 1,
      statusFilter: state.statusFilter,
      roleFilter: state.roleFilter,
      searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminModerationStatus.loaded,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: AdminModerationStatus.loaded,
        users: [...state.users, ...page.items],
        currentPage: state.currentPage + 1,
        hasMore: page.hasNextPage,
      )),
    );
  }

  Future<void> _onSearchChanged(
    AdminModerationSearchChanged event,
    Emitter<AdminModerationState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(AdminModerationFetchUsers(refresh: true));
  }

  Future<void> _onStatusFilterChanged(
    AdminModerationStatusFilterChanged event,
    Emitter<AdminModerationState> emit,
  ) async {
    emit(state.copyWith(statusFilter: () => event.status));
    add(AdminModerationFetchUsers(refresh: true));
  }

  Future<void> _onRoleFilterChanged(
    AdminModerationRoleFilterChanged event,
    Emitter<AdminModerationState> emit,
  ) async {
    emit(state.copyWith(roleFilter: () => event.role));
    add(AdminModerationFetchUsers(refresh: true));
  }

  Future<void> _onSelectUser(
    AdminModerationSelectUser event,
    Emitter<AdminModerationState> emit,
  ) async {
    final result = await _getUserDetail(UserIdParams(userId: event.userId));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (user) => emit(state.copyWith(selectedUser: user)),
    );
  }

  Future<void> _onModerateUser(
    AdminModerationModerateUser event,
    Emitter<AdminModerationState> emit,
  ) async {
    emit(state.copyWith(isModeratingUser: true));

    final result = await _moderateUser(ModerateUserParams(
      userId: event.userId,
      action: event.action,
      reason: event.reason,
      suspensionDuration: event.suspensionDuration,
      note: event.note,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isModeratingUser: false,
        errorMessage: failure.message,
      )),
      (updatedUser) {
        final updatedUsers = state.users
            .map((u) => u.id == updatedUser.id ? updatedUser : u)
            .toList();
        emit(state.copyWith(
          isModeratingUser: false,
          users: updatedUsers,
          selectedUser: updatedUser,
          moderationSuccess: 'Action applied successfully',
        ));
      },
    );
  }
}
