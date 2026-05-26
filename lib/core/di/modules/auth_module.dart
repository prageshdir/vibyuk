import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vibyuk/core/auth/auth_storage.dart';
import 'package:vibyuk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:vibyuk/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vibyuk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibyuk/features/auth/domain/usecases/biometric_login_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/login_with_email_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/login_with_google_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/logout_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/register_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/resend_email_otp_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/select_role_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/send_phone_otp_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/verify_email_otp_use_case.dart';
import 'package:vibyuk/features/auth/domain/usecases/verify_phone_otp_use_case.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';

void registerAuthModule(GetIt sl) {
  // Third-party
  sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(scopes: ['email', 'profile']),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<FlutterSecureStorage>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      authStorage: sl<AuthStorage>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendPhoneOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyPhoneOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyEmailOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResendEmailOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SelectRoleUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckSessionUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => BiometricLoginUseCase(sl<AuthRepository>(), sl<LocalAuthentication>()),
  );
  sl.registerLazySingleton(
    () => CheckBiometricAvailabilityUseCase(sl<LocalAuthentication>(), sl<AuthRepository>()),
  );

  // BLoC — factory so each provision gets a fresh instance
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      checkSession: sl<CheckSessionUseCase>(),
      loginWithEmail: sl<LoginWithEmailUseCase>(),
      loginWithGoogle: sl<LoginWithGoogleUseCase>(),
      sendPhoneOtp: sl<SendPhoneOtpUseCase>(),
      verifyPhoneOtp: sl<VerifyPhoneOtpUseCase>(),
      register: sl<RegisterUseCase>(),
      verifyEmailOtp: sl<VerifyEmailOtpUseCase>(),
      resendEmailOtp: sl<ResendEmailOtpUseCase>(),
      forgotPassword: sl<ForgotPasswordUseCase>(),
      resetPassword: sl<ResetPasswordUseCase>(),
      getCurrentUser: sl<GetCurrentUserUseCase>(),
      selectRole: sl<SelectRoleUseCase>(),
      biometricLogin: sl<BiometricLoginUseCase>(),
      logout: sl<LogoutUseCase>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );
}
