import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class BiometricLoginUseCase implements NoParamUseCase<UserEntity> {
  BiometricLoginUseCase(this._repository, this._localAuth);

  final AuthRepository _repository;
  final LocalAuthentication _localAuth;

  @override
  Future<Either<Failure, UserEntity>> call() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        return const Left(
          AuthFailure(message: 'Biometric authentication is not available on this device.'),
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access VIBYUK',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        return const Left(
          AuthFailure(message: 'Biometric authentication failed or was cancelled.'),
        );
      }

      return _repository.getCurrentUser();
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}

class CheckBiometricAvailabilityUseCase implements NoParamUseCase<bool> {
  CheckBiometricAvailabilityUseCase(this._localAuth, this._repository);

  final LocalAuthentication _localAuth;
  final AuthRepository _repository;

  @override
  Future<Either<Failure, bool>> call() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) return const Right(false);

      final isBiometricEnabled = await _repository.isBiometricEnabled();
      return isBiometricEnabled.fold(
        (_) => const Right(false),
        (enabled) => Right(enabled),
      );
    } catch (e) {
      return const Right(false);
    }
  }
}
