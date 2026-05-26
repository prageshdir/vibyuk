part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitialState extends AuthState {
  const AuthInitialState();
}

final class AuthLoadingState extends AuthState {
  final String? message;

  const AuthLoadingState({this.message});

  @override
  List<Object?> get props => [message];
}

final class AuthenticatedState extends AuthState {
  final UserEntity user;

  const AuthenticatedState({required this.user});

  @override
  List<Object?> get props => [user];
}

final class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

final class EmailVerificationRequiredState extends AuthState {
  final String email;

  const EmailVerificationRequiredState({required this.email});

  @override
  List<Object?> get props => [email];
}

final class EmailOtpResentState extends AuthState {
  final String email;

  const EmailOtpResentState({required this.email});

  @override
  List<Object?> get props => [email];
}

final class PhoneOtpSentState extends AuthState {
  final String phone;

  const PhoneOtpSentState({required this.phone});

  @override
  List<Object?> get props => [phone];
}

final class PasswordResetEmailSentState extends AuthState {
  final String email;

  const PasswordResetEmailSentState({required this.email});

  @override
  List<Object?> get props => [email];
}

final class PasswordResetSuccessState extends AuthState {
  const PasswordResetSuccessState();
}

final class RoleSelectionRequiredState extends AuthState {
  final UserEntity user;

  const RoleSelectionRequiredState({required this.user});

  @override
  List<Object?> get props => [user];
}

final class AuthErrorState extends AuthState {
  final Failure failure;

  const AuthErrorState({required this.failure});

  @override
  List<Object?> get props => [failure];
}

final class TwoFactorRequiredState extends AuthState {
  final TwoFactorMethod method;

  const TwoFactorRequiredState({required this.method});

  @override
  List<Object?> get props => [method];
}

final class TotpSetupLoadedState extends AuthState {
  final TotpSetupEntity totpSetup;

  const TotpSetupLoadedState({required this.totpSetup});

  @override
  List<Object?> get props => [totpSetup];
}

final class TotpEnabledState extends AuthState {
  const TotpEnabledState();
}

final class TotpDisabledState extends AuthState {
  const TotpDisabledState();
}

final class TotpVerifiedState extends AuthState {
  final UserEntity user;

  const TotpVerifiedState({required this.user});

  @override
  List<Object?> get props => [user];
}

final class AccountSuspendedState extends AuthState {
  final String? reason;
  final DateTime? suspendedAt;

  const AccountSuspendedState({this.reason, this.suspendedAt});

  @override
  List<Object?> get props => [reason, suspendedAt];
}
