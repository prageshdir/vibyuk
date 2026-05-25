class ForgotPasswordDto {
  final String email;

  const ForgotPasswordDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email.trim().toLowerCase()};
}

class ResetPasswordDto {
  final String token;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordDto({
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}
