import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/auth/auth_storage.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:vibyuk/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vibyuk/features/auth/data/dtos/login_request_dto.dart';
import 'package:vibyuk/features/auth/data/dtos/otp_request_dto.dart';
import 'package:vibyuk/features/auth/data/dtos/register_request_dto.dart';
import 'package:vibyuk/features/auth/data/dtos/reset_password_dto.dart';
import 'package:vibyuk/features/auth/data/dtos/role_selection_dto.dart';
import 'package:vibyuk/features/auth/domain/entities/auth_session_entity.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required AuthStorage authStorage,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _authStorage = authStorage;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final AuthStorage _authStorage;

  @override
  Future<Either<Failure, AuthSessionEntity>> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    return safeCall(
      () async {
        final dto = LoginRequestDto(email: email, password: password, rememberMe: rememberMe);
        final response = await _remote.loginWithEmail(dto);
        await _persistSession(response.toTokenModel(rememberMe: rememberMe), response.user.toJson());
        return response.toEntity(rememberMe: rememberMe);
      },
      context: 'AuthRepository.loginWithEmail',
    );
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> loginWithGoogle({
    required String idToken,
  }) async {
    return safeCall(
      () async {
        final response = await _remote.loginWithGoogle(idToken: idToken);
        await _persistSession(response.toTokenModel(), response.user.toJson());
        return response.toEntity();
      },
      context: 'AuthRepository.loginWithGoogle',
    );
  }

  @override
  Future<Either<Failure, String>> sendPhoneOtp({required String phone}) async {
    return safeCall(
      () => _remote.sendPhoneOtp(PhoneOtpSendDto(phone: phone)),
      context: 'AuthRepository.sendPhoneOtp',
    );
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    return safeCall(
      () async {
        final dto = PhoneOtpVerifyDto(phone: phone, otp: otp);
        final response = await _remote.verifyPhoneOtp(dto);
        await _persistSession(response.toTokenModel(), response.user.toJson());
        return response.toEntity();
      },
      context: 'AuthRepository.verifyPhoneOtp',
    );
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    return safeCall(
      () async {
        final dto = RegisterRequestDto(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          passwordConfirmation: password,
          phone: phone,
        );
        final response = await _remote.register(dto);
        await _persistSession(response.toTokenModel(), response.user.toJson());
        return response.toEntity();
      },
      context: 'AuthRepository.register',
    );
  }

  @override
  Future<Either<Failure, Unit>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    return safeCall(
      () async {
        await _remote.verifyEmailOtp(EmailOtpRequestDto(email: email, otp: otp));
        return unit;
      },
      context: 'AuthRepository.verifyEmailOtp',
    );
  }

  @override
  Future<Either<Failure, Unit>> resendEmailOtp({required String email}) async {
    return safeCall(
      () async {
        await _remote.resendEmailOtp(email: email);
        return unit;
      },
      context: 'AuthRepository.resendEmailOtp',
    );
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) async {
    return safeCall(
      () async {
        await _remote.forgotPassword(ForgotPasswordDto(email: email));
        return unit;
      },
      context: 'AuthRepository.forgotPassword',
    );
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return safeCall(
      () async {
        await _remote.resetPassword(
          ResetPasswordDto(
            token: token,
            password: password,
            passwordConfirmation: passwordConfirmation,
          ),
        );
        return unit;
      },
      context: 'AuthRepository.resetPassword',
    );
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    return safeCall(
      () async {
        final model = await _remote.getMe();
        await _local.saveUser(model);
        return model.toEntity();
      },
      context: 'AuthRepository.getCurrentUser',
    );
  }

  @override
  Future<Either<Failure, UserEntity>> selectRole({required UserRole role}) async {
    return safeCall(
      () async {
        final model = await _remote.selectRole(RoleSelectionDto(role: role));
        await _local.saveUser(model);
        return model.toEntity();
      },
      context: 'AuthRepository.selectRole',
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    return safeCall(
      () async {
        try {
          await _remote.logout();
        } catch (_) {
          // Best-effort server logout; always clear local session
        }
        await _authStorage.clearAll();
        await _local.clearUser();
        return unit;
      },
      context: 'AuthRepository.logout',
    );
  }

  @override
  Future<Either<Failure, bool>> hasValidSession() async {
    return safeCall(
      () => _authStorage.hasValidSession(),
      context: 'AuthRepository.hasValidSession',
    );
  }

  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    return safeCall(
      () async {
        final model = await _local.getUser();
        return model?.toEntity();
      },
      context: 'AuthRepository.getCachedUser',
    );
  }

  @override
  Future<Either<Failure, Unit>> saveBiometricEnabled({required bool enabled}) async {
    return safeCall(
      () async {
        await _local.setBiometricEnabled(enabled);
        return unit;
      },
      context: 'AuthRepository.saveBiometricEnabled',
    );
  }

  @override
  Future<Either<Failure, bool>> isBiometricEnabled() async {
    return safeCall(
      () => _local.isBiometricEnabled(),
      context: 'AuthRepository.isBiometricEnabled',
    );
  }

  Future<void> _persistSession(
    dynamic tokenModel,
    Map<String, dynamic> userData,
  ) async {
    await _authStorage.saveTokens(tokenModel);
    await _authStorage.saveUserData(userData);
  }
}
