import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/repositories/notifications_repository.dart';

class MarkNotificationReadUseCase
    implements UseCase<Unit, MarkNotificationReadParams> {
  MarkNotificationReadUseCase(this._repository);
  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(MarkNotificationReadParams params) {
    return _repository.markNotificationRead(params.notificationId);
  }
}

class MarkNotificationReadParams extends Equatable {
  const MarkNotificationReadParams({required this.notificationId});
  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}
