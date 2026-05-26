import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class SaveNotificationUseCase implements UseCase<Unit, SaveNotificationParams> {
  const SaveNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveNotificationParams params) =>
      _repository.saveNotification(params.entity);
}

class SaveNotificationParams extends Equatable {
  final NotificationEntity entity;

  const SaveNotificationParams(this.entity);

  @override
  List<Object?> get props => [entity];
}
