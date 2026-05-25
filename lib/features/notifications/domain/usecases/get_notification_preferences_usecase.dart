import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationPreferencesUseCase
    implements NoParamUseCase<NotificationPreferences> {
  const GetNotificationPreferencesUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, NotificationPreferences>> call() =>
      _repository.getPreferences();
}
