import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllReadUseCase implements NoParamUseCase<Unit> {
  const MarkAllReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call() => _repository.markAllAsRead();
}
