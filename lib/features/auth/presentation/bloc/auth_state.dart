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
