import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';
import 'package:vibyuk/features/admin/domain/repositories/admin_repository.dart';

class GetUsersUseCase implements UseCase<PaginatedResponse<AdminUser>, GetUsersParams> {
  final AdminRepository _repository;

  const GetUsersUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<AdminUser>>> call(GetUsersParams params) {
    return _repository.getUsers(
      page: params.page,
      statusFilter: params.statusFilter,
      roleFilter: params.roleFilter,
      searchQuery: params.searchQuery,
    );
  }
}

class GetUserDetailUseCase implements UseCase<AdminUser, UserIdParams> {
  final AdminRepository _repository;

  const GetUserDetailUseCase(this._repository);

  @override
  Future<Either<Failure, AdminUser>> call(UserIdParams params) {
    return _repository.getUserDetail(userId: params.userId);
  }
}

class ModerateUserUseCase implements UseCase<AdminUser, ModerateUserParams> {
  final AdminRepository _repository;

  const ModerateUserUseCase(this._repository);

  @override
  Future<Either<Failure, AdminUser>> call(ModerateUserParams params) {
    return _repository.moderateUser(
      userId: params.userId,
      action: params.action,
      reason: params.reason,
      suspensionDuration: params.suspensionDuration,
      note: params.note,
    );
  }
}

// ── Params ────────────────────────────────────────────────────────────────────

class GetUsersParams extends Equatable {
  final int page;
  final AdminUserStatus? statusFilter;
  final AdminUserRole? roleFilter;
  final String? searchQuery;

  const GetUsersParams({
    this.page = 1,
    this.statusFilter,
    this.roleFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page, statusFilter, roleFilter, searchQuery];
}

class UserIdParams extends Equatable {
  final String userId;

  const UserIdParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ModerateUserParams extends Equatable {
  final String userId;
  final ModerationAction action;
  final String? reason;
  final Duration? suspensionDuration;
  final String? note;

  const ModerateUserParams({
    required this.userId,
    required this.action,
    this.reason,
    this.suspensionDuration,
    this.note,
  });

  @override
  List<Object?> get props => [userId, action, reason, suspensionDuration, note];
}
