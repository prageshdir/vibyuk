import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class UpdateNotificationPreferencesUseCase
    implements UseCase<Unit, UpdatePreferencesParams> {
  const UpdateNotificationPreferencesUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdatePreferencesParams params) =>
      _repository.updatePreferences(params.preferences);
}

class UpdatePreferencesParams extends Equatable {
  final NotificationPreferences preferences;

  const UpdatePreferencesParams(this.preferences);

  @override
  List<Object?> get props => [preferences];
}
