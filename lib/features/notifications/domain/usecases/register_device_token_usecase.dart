import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class RegisterDeviceTokenUseCase implements UseCase<Unit, DeviceTokenParams> {
  const RegisterDeviceTokenUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeviceTokenParams params) =>
      _repository.registerDeviceToken(params.token);
}

class DeviceTokenParams extends Equatable {
  final String token;

  const DeviceTokenParams(this.token);

  @override
  List<Object?> get props => [token];
}
