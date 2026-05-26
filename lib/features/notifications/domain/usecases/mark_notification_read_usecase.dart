import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase implements UseCase<Unit, MarkReadParams> {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(MarkReadParams params) =>
      _repository.markAsRead(params.notificationId);
}

class MarkReadParams extends Equatable {
  final String notificationId;

  const MarkReadParams(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}
