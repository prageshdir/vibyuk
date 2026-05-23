import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
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
import 'package:vibyuk/core/base/use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends BaseBloc<AuthEvent, AuthState> {
  AuthBloc({
    required CheckSessionUseCase checkSession,
    required LoginWithEmailUseCase loginWithEmail,
    required LoginWithGoogleUseCase loginWithGoogle,
    required SendPhoneOtpUseCase sendPhoneOtp,
    required VerifyPhoneOtpUseCase verifyPhoneOtp,
    required RegisterUseCase register,
    required VerifyEmailOtpUseCase verifyEmailOtp,
    required ResendEmailOtpUseCase resendEmailOtp,
    required ForgotPasswordUseCase forgotPassword,
    required ResetPasswordUseCase resetPassword,
    required GetCurrentUserUseCase getCurrentUser,
    required SelectRoleUseCase selectRole,
    required BiometricLoginUseCase biometricLogin,
    required LogoutUseCase logout,
    required GoogleSignIn googleSignIn,
  })  : _checkSession = checkSession,
        _loginWithEmail = loginWithEmail,
        _loginWithGoogle = loginWithGoogle,
        _sendPhoneOtp = sendPhoneOtp,
        _verifyPhoneOtp = verifyPhoneOtp,
        _register = register,
        _verifyEmailOtp = verifyEmailOtp,
        _resendEmailOtp = resendEmailOtp,
        _forgotPassword = forgotPassword,
        _resetPassword = resetPassword,
        _getCurrentUser = getCurrentUser,
        _selectRole = selectRole,
        _biometricLogin = biometricLogin,
        _logout = logout,
        _googleSignIn = googleSignIn,
        super(const AuthInitialState()) {
    on<CheckSessionEvent>(_onCheckSession);
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<SendPhoneOtpEvent>(_onSendPhoneOtp);
    on<VerifyPhoneOtpEvent>(_onVerifyPhoneOtp);
    on<RegisterEvent>(_onRegister);
    on<VerifyEmailOtpEvent>(_onVerifyEmailOtp);
    on<ResendEmailOtpEvent>(_onResendEmailOtp);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<SelectRoleEvent>(_onSelectRole);
    on<BiometricLoginEvent>(_onBiometricLogin);
    on<LogoutEvent>(_onLogout);
    on<AuthErrorClearedEvent>(_onErrorCleared);
  }

  final CheckSessionUseCase _checkSession;
  final LoginWithEmailUseCase _loginWithEmail;
  final LoginWithGoogleUseCase _loginWithGoogle;
  final SendPhoneOtpUseCase _sendPhoneOtp;
  final VerifyPhoneOtpUseCase _verifyPhoneOtp;
  final RegisterUseCase _register;
  final VerifyEmailOtpUseCase _verifyEmailOtp;
  final ResendEmailOtpUseCase _resendEmailOtp;
  final ForgotPasswordUseCase _forgotPassword;
  final ResetPasswordUseCase _resetPassword;
  final GetCurrentUserUseCase _getCurrentUser;
  final SelectRoleUseCase _selectRole;
  final BiometricLoginUseCase _biometricLogin;
  final LogoutUseCase _logout;
  final GoogleSignIn _googleSignIn;

  Future<void> _onCheckSession(
    CheckSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final sessionResult = await _checkSession();
    await sessionResult.fold(
      (_) async => emit(const UnauthenticatedState()),
      (hasSession) async {
        if (!hasSession) return emit(const UnauthenticatedState());
        final userResult = await _getCurrentUser();
        userResult.fold(
          (_) => emit(const UnauthenticatedState()),
          (user) => emit(_resolveAuthenticatedState(user)),
        );
      },
    );
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _loginWithEmail(
      LoginWithEmailParams(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      ),
    );
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (session) {
        final user = session.user;
        if (!user.isEmailVerified) {
          emit(EmailVerificationRequiredState(email: user.email));
        } else {
          emit(_resolveAuthenticatedState(user));
        }
      },
    );
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(const UnauthenticatedState());
        return;
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        emit(const AuthErrorState(
          failure: AuthFailure(message: 'Google sign-in failed. Please try again.'),
        ));
        return;
      }
      final result = await _loginWithGoogle(LoginWithGoogleParams(idToken: idToken));
      result.fold(
        (failure) => emit(AuthErrorState(failure: failure)),
        (session) => emit(_resolveAuthenticatedState(session.user)),
      );
    } catch (e) {
      emit(AuthErrorState(
        failure: AuthFailure(message: 'Google sign-in failed: ${e.toString()}'),
      ));
    }
  }

  Future<void> _onSendPhoneOtp(
    SendPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _sendPhoneOtp(SendPhoneOtpParams(phone: event.phone));
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (_) => emit(PhoneOtpSentState(phone: event.phone)),
    );
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _verifyPhoneOtp(
      VerifyPhoneOtpParams(phone: event.phone, otp: event.otp),
    );
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (session) => emit(_resolveAuthenticatedState(session.user)),
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _register(
      RegisterParams(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        phone: event.phone,
      ),
    );
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (session) => emit(EmailVerificationRequiredState(email: session.user.email)),
    );
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _verifyEmailOtp(
      VerifyEmailOtpParams(email: event.email, otp: event.otp),
    );
    await result.fold(
      (failure) async => emit(AuthErrorState(failure: failure)),
      (_) async {
        final userResult = await _getCurrentUser();
        userResult.fold(
          (_) => emit(const UnauthenticatedState()),
          (user) => emit(_resolveAuthenticatedState(user)),
        );
      },
    );
  }

  Future<void> _onResendEmailOtp(
    ResendEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState(message: 'Resending OTP...'));
    final result = await _resendEmailOtp(ResendEmailOtpParams(email: event.email));
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (_) => emit(EmailOtpResentState(email: event.email)),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _forgotPassword(ForgotPasswordParams(email: event.email));
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (_) => emit(PasswordResetEmailSentState(email: event.email)),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _resetPassword(
      ResetPasswordParams(
        token: event.token,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      ),
    );
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (_) => emit(const PasswordResetSuccessState()),
    );
  }

  Future<void> _onSelectRole(
    SelectRoleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _selectRole(SelectRoleParams(role: event.role));
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (user) => emit(AuthenticatedState(user: user)),
    );
  }

  Future<void> _onBiometricLogin(
    BiometricLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Verifying biometrics...'));
    final result = await _biometricLogin();
    result.fold(
      (failure) => emit(AuthErrorState(failure: failure)),
      (user) => emit(_resolveAuthenticatedState(user)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    await _googleSignIn.signOut().catchError((_) {});
    await _logout();
    emit(const UnauthenticatedState());
  }

  void _onErrorCleared(
    AuthErrorClearedEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const UnauthenticatedState());
  }

  AuthState _resolveAuthenticatedState(UserEntity user) {
    if (!user.hasRole) {
      return RoleSelectionRequiredState(user: user);
    }
    return AuthenticatedState(user: user);
  }
}
