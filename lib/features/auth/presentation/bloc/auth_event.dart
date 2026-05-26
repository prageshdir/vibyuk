part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class CheckSessionEvent extends AuthEvent {
  const CheckSessionEvent();
}

final class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginWithEmailEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

final class LoginWithGoogleEvent extends AuthEvent {
  const LoginWithGoogleEvent();
}

final class SendPhoneOtpEvent extends AuthEvent {
  final String phone;

  const SendPhoneOtpEvent({required this.phone});

  @override
  List<Object?> get props => [phone];
}

final class VerifyPhoneOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyPhoneOtpEvent({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

final class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phone;

  const RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password, phone];
}

final class VerifyEmailOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const VerifyEmailOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

final class ResendEmailOtpEvent extends AuthEvent {
  final String email;

  const ResendEmailOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

final class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

final class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordEvent({
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [token, password, passwordConfirmation];
}

final class SelectRoleEvent extends AuthEvent {
  final UserRole role;

  const SelectRoleEvent({required this.role});

  @override
  List<Object?> get props => [role];
}

final class BiometricLoginEvent extends AuthEvent {
  const BiometricLoginEvent();
}

final class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

final class AuthErrorClearedEvent extends AuthEvent {
  const AuthErrorClearedEvent();
}

final class GetTotpSetupEvent extends AuthEvent {
  const GetTotpSetupEvent();
}

final class EnableTotpEvent extends AuthEvent {
  final String totpCode;

  const EnableTotpEvent({required this.totpCode});

  @override
  List<Object?> get props => [totpCode];
}

final class DisableTotpEvent extends AuthEvent {
  final String password;

  const DisableTotpEvent({required this.password});

  @override
  List<Object?> get props => [password];
}

final class VerifyTotpEvent extends AuthEvent {
  final String token;

  const VerifyTotpEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

final class VerifyTotpRecoveryEvent extends AuthEvent {
  final String recoveryCode;

  const VerifyTotpRecoveryEvent({required this.recoveryCode});

  @override
  List<Object?> get props => [recoveryCode];
}
