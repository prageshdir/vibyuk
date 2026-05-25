import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';

class GetNotificationsUseCase
    implements UseCase<PaginatedResponse<NotificationEntity>, GetNotificationsParams> {
  const GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) {
    return _repository.getNotifications(
      page: params.page,
      perPage: params.perPage,
      filter: params.filter,
    );
  }
}

class GetNotificationsParams extends Equatable {
  final int page;
  final int perPage;
  final NotificationFilter filter;

  const GetNotificationsParams({
    this.page = 1,
    this.perPage = 20,
    this.filter = NotificationFilter.all,
  });

  @override
  List<Object?> get props => [page, perPage, filter];
}
