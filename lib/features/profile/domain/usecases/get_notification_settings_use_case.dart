import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/entities/notification_settings_entity.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class GetNotificationSettingsUseCase implements NoParamUseCase<NotificationSettingsEntity> {
  GetNotificationSettingsUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, NotificationSettingsEntity>> call() {
    return _repository.getNotificationSettings();
  }
}
