import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/auth_session_entity.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
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

// ── Fake use cases ────────────────────────────────────────────────────────────

class _FakeCheckSession extends Fake implements CheckSessionUseCase {
  Either<Failure, bool> result;
  _FakeCheckSession(this.result);
  @override
  Future<Either<Failure, bool>> call() async => result;
}

class _FakeGetCurrentUser extends Fake implements GetCurrentUserUseCase {
  Either<Failure, UserEntity> result;
  _FakeGetCurrentUser(this.result);
  @override
  Future<Either<Failure, UserEntity>> call() async => result;
}

class _FakeLoginWithEmail extends Fake implements LoginWithEmailUseCase {
  Either<Failure, AuthSessionEntity> result;
  _FakeLoginWithEmail(this.result);
  @override
  Future<Either<Failure, AuthSessionEntity>> call(LoginWithEmailParams params) async => result;
}

class _FakeLoginWithGoogle extends Fake implements LoginWithGoogleUseCase {
  Either<Failure, AuthSessionEntity> result;
  _FakeLoginWithGoogle(this.result);
  @override
  Future<Either<Failure, AuthSessionEntity>> call(LoginWithGoogleParams params) async => result;
}

class _FakeRegister extends Fake implements RegisterUseCase {
  Either<Failure, AuthSessionEntity> result;
  _FakeRegister(this.result);
  @override
  Future<Either<Failure, AuthSessionEntity>> call(RegisterParams params) async => result;
}

class _FakeSendPhoneOtp extends Fake implements SendPhoneOtpUseCase {
  Either<Failure, String> result = const Right('sent');
  @override
  Future<Either<Failure, String>> call(SendPhoneOtpParams params) async => result;
}

class _FakeVerifyPhoneOtp extends Fake implements VerifyPhoneOtpUseCase {
  Either<Failure, AuthSessionEntity> result;
  _FakeVerifyPhoneOtp(this.result);
  @override
  Future<Either<Failure, AuthSessionEntity>> call(VerifyPhoneOtpParams params) async => result;
}

class _FakeVerifyEmailOtp extends Fake implements VerifyEmailOtpUseCase {
  Either<Failure, Unit> result = const Right(unit);
  @override
  Future<Either<Failure, Unit>> call(VerifyEmailOtpParams params) async => result;
}

class _FakeResendEmailOtp extends Fake implements ResendEmailOtpUseCase {
  @override
  Future<Either<Failure, Unit>> call(ResendEmailOtpParams params) async => const Right(unit);
}

class _FakeForgotPassword extends Fake implements ForgotPasswordUseCase {
  @override
  Future<Either<Failure, Unit>> call(ForgotPasswordParams params) async => const Right(unit);
}

class _FakeResetPassword extends Fake implements ResetPasswordUseCase {
  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) async => const Right(unit);
}

class _FakeSelectRole extends Fake implements SelectRoleUseCase {
  Either<Failure, UserEntity> result;
  _FakeSelectRole(this.result);
  @override
  Future<Either<Failure, UserEntity>> call(SelectRoleParams params) async => result;
}

class _FakeBiometricLogin extends Fake implements BiometricLoginUseCase {
  Either<Failure, UserEntity> result;
  _FakeBiometricLogin(this.result);
  @override
  Future<Either<Failure, UserEntity>> call() async => result;
}

class _FakeLogout extends Fake implements LogoutUseCase {
  @override
  Future<Either<Failure, Unit>> call() async => const Right(unit);
}

class _FakeGoogleSignIn extends Fake implements GoogleSignIn {
  GoogleSignInAccount? signInResult;
  @override
  Future<GoogleSignInAccount?> signIn() async => signInResult;
  @override
  Future<GoogleSignInAccount?> signOut() async => null;
}

// ── Test data ─────────────────────────────────────────────────────────────────

UserEntity _user({
  String id = 'u-1',
  String email = 'alice@example.com',
  bool emailVerified = true,
  UserRole? role = UserRole.creator,
}) =>
    UserEntity(
      id: id,
      email: email,
      firstName: 'Alice',
      isEmailVerified: emailVerified,
      role: role,
      createdAt: DateTime(2024),
    );

AuthSessionEntity _session({bool emailVerified = true, UserRole? role = UserRole.creator}) =>
    AuthSessionEntity(
      user: _user(emailVerified: emailVerified, role: role),
      accessToken: 'access',
      refreshToken: 'refresh',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

// ── BLoC factory ─────────────────────────────────────────────────────────────

AuthBloc _bloc({
  Either<Failure, bool>? sessionResult,
  Either<Failure, UserEntity>? userResult,
  Either<Failure, AuthSessionEntity>? loginResult,
  Either<Failure, AuthSessionEntity>? registerResult,
  Either<Failure, AuthSessionEntity>? verifyPhoneResult,
  Either<Failure, UserEntity>? selectRoleResult,
  Either<Failure, UserEntity>? biometricResult,
  _FakeGoogleSignIn? googleSignIn,
}) {
  return AuthBloc(
    checkSession: _FakeCheckSession(sessionResult ?? const Right(false)),
    loginWithEmail: _FakeLoginWithEmail(loginResult ?? Right(_session())),
    loginWithGoogle: _FakeLoginWithGoogle(loginResult ?? Right(_session())),
    sendPhoneOtp: _FakeSendPhoneOtp(),
    verifyPhoneOtp: _FakeVerifyPhoneOtp(verifyPhoneResult ?? Right(_session())),
    register: _FakeRegister(registerResult ?? Right(_session())),
    verifyEmailOtp: _FakeVerifyEmailOtp(),
    resendEmailOtp: _FakeResendEmailOtp(),
    forgotPassword: _FakeForgotPassword(),
    resetPassword: _FakeResetPassword(),
    getCurrentUser: _FakeGetCurrentUser(userResult ?? Right(_user())),
    selectRole: _FakeSelectRole(selectRoleResult ?? Right(_user())),
    biometricLogin: _FakeBiometricLogin(biometricResult ?? Right(_user())),
    logout: _FakeLogout(),
    googleSignIn: googleSignIn ?? _FakeGoogleSignIn(),
  );
}

void main() {
  setUpAll(() => FlavorConfig.initialize(AppFlavor.dev));

  group('AuthBloc', () {
    test('initial state is AuthInitialState', () {
      final bloc = _bloc();
      expect(bloc.state, isA<AuthInitialState>());
      bloc.close();
    });

    // ── CheckSession ────────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'CheckSessionEvent emits Loading → Authenticated when session is valid',
      build: () => _bloc(
        sessionResult: const Right(true),
        userResult: Right(_user()),
      ),
      act: (b) => b.add(const CheckSessionEvent()),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthenticatedState>().having((s) => s.user.email, 'email', 'alice@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'CheckSessionEvent emits Loading → Unauthenticated when no session',
      build: () => _bloc(sessionResult: const Right(false)),
      act: (b) => b.add(const CheckSessionEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<UnauthenticatedState>()],
    );

    blocTest<AuthBloc, AuthState>(
      'CheckSessionEvent emits Loading → Unauthenticated on session failure',
      build: () => _bloc(
        sessionResult: const Left(ServerFailure(message: 'error')),
      ),
      act: (b) => b.add(const CheckSessionEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<UnauthenticatedState>()],
    );

    blocTest<AuthBloc, AuthState>(
      'CheckSessionEvent emits RoleSelectionRequired when user has no role',
      build: () => _bloc(
        sessionResult: const Right(true),
        userResult: Right(_user(role: null)),
      ),
      act: (b) => b.add(const CheckSessionEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<RoleSelectionRequiredState>()],
    );

    // ── LoginWithEmail ──────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'LoginWithEmailEvent emits Loading → Authenticated on success',
      build: () => _bloc(loginResult: Right(_session())),
      act: (b) => b.add(
        const LoginWithEmailEvent(email: 'alice@example.com', password: 'pass'),
      ),
      expect: () => [isA<AuthLoadingState>(), isA<AuthenticatedState>()],
    );

    blocTest<AuthBloc, AuthState>(
      'LoginWithEmailEvent emits Loading → AuthError on failure',
      build: () => _bloc(
        loginResult: const Left(AuthFailure(message: 'Invalid credentials')),
      ),
      act: (b) => b.add(
        const LoginWithEmailEvent(email: 'alice@example.com', password: 'wrong'),
      ),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthErrorState>()
            .having((s) => s.failure, 'failure', isA<AuthFailure>()),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'LoginWithEmailEvent emits EmailVerificationRequired when email not verified',
      build: () => _bloc(loginResult: Right(_session(emailVerified: false))),
      act: (b) => b.add(
        const LoginWithEmailEvent(email: 'alice@example.com', password: 'pass'),
      ),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<EmailVerificationRequiredState>()
            .having((s) => s.email, 'email', 'alice@example.com'),
      ],
    );

    // ── Register ────────────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'RegisterEvent emits Loading → EmailVerificationRequired',
      build: () => _bloc(registerResult: Right(_session(emailVerified: false))),
      act: (b) => b.add(
        const RegisterEvent(
          firstName: 'Alice',
          lastName: 'Smith',
          email: 'alice@example.com',
          password: 'pass123',
        ),
      ),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<EmailVerificationRequiredState>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'RegisterEvent emits AuthError on server failure',
      build: () => _bloc(
        registerResult: const Left(ServerFailure(message: 'Email taken')),
      ),
      act: (b) => b.add(
        const RegisterEvent(
          firstName: 'Alice',
          lastName: 'Smith',
          email: 'alice@example.com',
          password: 'pass123',
        ),
      ),
      expect: () => [isA<AuthLoadingState>(), isA<AuthErrorState>()],
    );

    // ── Logout ──────────────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'LogoutEvent emits Loading → Unauthenticated',
      build: () => _bloc(),
      act: (b) => b.add(const LogoutEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<UnauthenticatedState>()],
    );

    // ── BiometricLogin ──────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'BiometricLoginEvent emits Loading → Authenticated on success',
      build: () => _bloc(biometricResult: Right(_user())),
      act: (b) => b.add(const BiometricLoginEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<AuthenticatedState>()],
    );

    blocTest<AuthBloc, AuthState>(
      'BiometricLoginEvent emits AuthError on failure',
      build: () => _bloc(
        biometricResult: const Left(AuthFailure(message: 'Biometric failed')),
      ),
      act: (b) => b.add(const BiometricLoginEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<AuthErrorState>()],
    );

    // ── SelectRole ──────────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'SelectRoleEvent emits Loading → Authenticated',
      build: () => _bloc(selectRoleResult: Right(_user(role: UserRole.creator))),
      act: (b) => b.add(const SelectRoleEvent(role: UserRole.creator)),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthenticatedState>()
            .having((s) => s.user.role, 'role', UserRole.creator),
      ],
    );

    // ── SendPhoneOtp ────────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'SendPhoneOtpEvent emits Loading → PhoneOtpSentState',
      build: () => _bloc(),
      act: (b) => b.add(const SendPhoneOtpEvent(phone: '+447700900000')),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<PhoneOtpSentState>()
            .having((s) => s.phone, 'phone', '+447700900000'),
      ],
    );

    // ── ForgotPassword ──────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'ForgotPasswordEvent emits Loading → PasswordResetEmailSentState',
      build: () => _bloc(),
      act: (b) => b.add(const ForgotPasswordEvent(email: 'alice@example.com')),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<PasswordResetEmailSentState>()
            .having((s) => s.email, 'email', 'alice@example.com'),
      ],
    );

    // ── AuthErrorCleared ────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'AuthErrorClearedEvent resets to Unauthenticated',
      build: () => _bloc(),
      act: (b) => b.add(const AuthErrorClearedEvent()),
      expect: () => [isA<UnauthenticatedState>()],
    );

    // ── GoogleSignIn cancelled ──────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'LoginWithGoogleEvent emits Unauthenticated when user cancels sign-in',
      build: () {
        final google = _FakeGoogleSignIn()..signInResult = null;
        return _bloc(googleSignIn: google);
      },
      act: (b) => b.add(const LoginWithGoogleEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<UnauthenticatedState>()],
    );
  });
}
