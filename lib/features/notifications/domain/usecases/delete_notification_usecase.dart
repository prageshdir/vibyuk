import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class DeleteNotificationUseCase implements UseCase<Unit, DeleteNotificationParams> {
  const DeleteNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteNotificationParams params) =>
      _repository.deleteNotification(params.notificationId);
}

class DeleteNotificationParams extends Equatable {
  final String notificationId;

  const DeleteNotificationParams(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}
