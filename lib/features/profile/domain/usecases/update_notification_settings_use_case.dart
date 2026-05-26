import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/entities/notification_settings_entity.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class UpdateNotificationSettingsUseCase
    implements UseCase<NotificationSettingsEntity, UpdateNotificationSettingsParams> {
  UpdateNotificationSettingsUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, NotificationSettingsEntity>> call(
    UpdateNotificationSettingsParams params,
  ) {
    return _repository.updateNotificationSettings(params.settings);
  }
}

class UpdateNotificationSettingsParams extends Equatable {
  final NotificationSettingsEntity settings;

  const UpdateNotificationSettingsParams({required this.settings});

  @override
  List<Object?> get props => [settings];
}
