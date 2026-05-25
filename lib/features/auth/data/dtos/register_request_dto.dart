class RegisterRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String? phone;

  const RegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
      };
}
