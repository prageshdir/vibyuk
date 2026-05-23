class LoginRequestDto {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequestDto({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'password': password,
        'remember_me': rememberMe,
      };
}
