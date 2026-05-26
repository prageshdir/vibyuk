import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/auth_session_entity.dart';
import 'package:vibyuk/features/auth/domain/entities/totp_setup_entity.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthSessionEntity>> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, AuthSessionEntity>> loginWithGoogle({
    required String idToken,
  });

  Future<Either<Failure, String>> sendPhoneOtp({
    required String phone,
  });

  Future<Either<Failure, AuthSessionEntity>> verifyPhoneOtp({
    required String phone,
    required String otp,
  });

  Future<Either<Failure, AuthSessionEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  });

  Future<Either<Failure, Unit>> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Unit>> resendEmailOtp({
    required String email,
  });

  Future<Either<Failure, Unit>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, UserEntity>> selectRole({
    required UserRole role,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, bool>> hasValidSession();

  Future<Either<Failure, UserEntity?>> getCachedUser();

  Future<Either<Failure, Unit>> saveBiometricEnabled({
    required bool enabled,
  });

  Future<Either<Failure, bool>> isBiometricEnabled();

  // 2FA / TOTP
  Future<Either<Failure, TotpSetupEntity>> getTotpSetup();
  Future<Either<Failure, Unit>> enableTotp({required String totpCode});
  Future<Either<Failure, Unit>> disableTotp({required String password});
  Future<Either<Failure, bool>> verifyTotpToken({required String token});
  Future<Either<Failure, bool>> verifyTotpRecovery({required String recoveryCode});
}
