import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/notification_item_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase
    implements UseCase<PaginatedResult<NotificationItemEntity>, GetNotificationsParams> {
  GetNotificationsUseCase(this._repository);
  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<NotificationItemEntity>>> call(
      GetNotificationsParams params) {
    return _repository.getNotifications(
      page: params.page,
      pageSize: params.pageSize,
      unreadOnly: params.unreadOnly,
    );
  }
}

class GetNotificationsParams extends Equatable {
  const GetNotificationsParams({
    this.page = 1,
    this.pageSize = 20,
    this.unreadOnly = false,
  });
  final int page;
  final int pageSize;
  final bool unreadOnly;

  @override
  List<Object?> get props => [page, pageSize, unreadOnly];
}
