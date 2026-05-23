class EmailOtpRequestDto {
  final String email;
  final String otp;

  const EmailOtpRequestDto({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      };
}

class PhoneOtpSendDto {
  final String phone;

  const PhoneOtpSendDto({required this.phone});

  Map<String, dynamic> toJson() => {'phone': phone.trim()};
}

class PhoneOtpVerifyDto {
  final String phone;
  final String otp;

  const PhoneOtpVerifyDto({required this.phone, required this.otp});

  Map<String, dynamic> toJson() => {
        'phone': phone.trim(),
        'otp': otp.trim(),
      };
}
