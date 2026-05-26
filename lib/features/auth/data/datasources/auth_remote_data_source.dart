import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/features/auth/data/dtos/login_request_dto.dart';
import 'package:vibyuk/features/auth/data/dtos/otp_request_dto.dart';
import 'package:vibyuk/features/auth/data/dtos/register_request_dto.dart';
import 'package:vibyuk/features/auth/data/dtos/reset_password_dto.dart';
import 'package:vibyuk/features/auth/data/dtos/role_selection_dto.dart';
import 'package:vibyuk/features/auth/data/models/auth_response_model.dart';
import 'package:vibyuk/features/auth/data/models/user_model.dart';
import 'package:vibyuk/features/auth/domain/entities/totp_setup_entity.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> loginWithEmail(LoginRequestDto dto);
  Future<AuthResponseModel> loginWithGoogle({required String idToken});
  Future<String> sendPhoneOtp(PhoneOtpSendDto dto);
  Future<AuthResponseModel> verifyPhoneOtp(PhoneOtpVerifyDto dto);
  Future<AuthResponseModel> register(RegisterRequestDto dto);
  Future<void> verifyEmailOtp(EmailOtpRequestDto dto);
  Future<void> resendEmailOtp({required String email});
  Future<void> forgotPassword(ForgotPasswordDto dto);
  Future<void> resetPassword(ResetPasswordDto dto);
  Future<UserModel> getMe();
  Future<UserModel> selectRole(RoleSelectionDto dto);
  Future<void> logout();

  // 2FA / TOTP
  Future<TotpSetupEntity> getTotpSetup();
  Future<void> enableTotp({required String totpCode});
  Future<void> disableTotp({required String password});
  Future<bool> verifyTotpToken({required String token});
  Future<bool> verifyTotpRecovery({required String recoveryCode});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> loginWithEmail(LoginRequestDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: dto.toJson(),
    );
    return AuthResponseModel.fromJson(_extractData(response));
  }

  @override
  Future<AuthResponseModel> loginWithGoogle({required String idToken}) async {
    final response = await _dio.post(
      ApiEndpoints.googleSignIn,
      data: {'id_token': idToken},
    );
    return AuthResponseModel.fromJson(_extractData(response));
  }

  @override
  Future<String> sendPhoneOtp(PhoneOtpSendDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.sendPhoneOtp,
      data: dto.toJson(),
    );
    final data = _extractData(response);
    return data['message'] as String? ?? 'OTP sent successfully.';
  }

  @override
  Future<AuthResponseModel> verifyPhoneOtp(PhoneOtpVerifyDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.verifyPhoneOtp,
      data: dto.toJson(),
    );
    return AuthResponseModel.fromJson(_extractData(response));
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: dto.toJson(),
    );
    return AuthResponseModel.fromJson(_extractData(response));
  }

  @override
  Future<void> verifyEmailOtp(EmailOtpRequestDto dto) async {
    await _dio.post(
      ApiEndpoints.verifyEmail,
      data: dto.toJson(),
    );
  }

  @override
  Future<void> resendEmailOtp({required String email}) async {
    await _dio.post(
      ApiEndpoints.resendVerification,
      data: {'email': email.trim().toLowerCase()},
    );
  }

  @override
  Future<void> forgotPassword(ForgotPasswordDto dto) async {
    await _dio.post(
      ApiEndpoints.forgotPassword,
      data: dto.toJson(),
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordDto dto) async {
    await _dio.post(
      ApiEndpoints.resetPassword,
      data: dto.toJson(),
    );
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(_extractData(response));
  }

  @override
  Future<UserModel> selectRole(RoleSelectionDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.selectRole,
      data: dto.toJson(),
    );
    return UserModel.fromJson(_extractData(response));
  }

  @override
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }

  @override
  Future<TotpSetupEntity> getTotpSetup() async {
    final response = await _dio.post(ApiEndpoints.twoFactorTotpSetup);
    final data = _extractData(response);
    return TotpSetupEntity(
      secret: data['secret'] as String,
      qrCodeUri: data['qr_code_uri'] as String,
      recoveryCodes: (data['recovery_codes'] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  Future<void> enableTotp({required String totpCode}) async {
    await _dio.post(
      ApiEndpoints.twoFactorTotpEnable,
      data: {'totp_code': totpCode},
    );
  }

  @override
  Future<void> disableTotp({required String password}) async {
    await _dio.post(
      ApiEndpoints.twoFactorTotpDisable,
      data: {'password': password},
    );
  }

  @override
  Future<bool> verifyTotpToken({required String token}) async {
    final response = await _dio.post(
      ApiEndpoints.twoFactorTotpVerify,
      data: {'token': token},
    );
    final data = _extractData(response);
    return data['verified'] as bool? ?? false;
  }

  @override
  Future<bool> verifyTotpRecovery({required String recoveryCode}) async {
    final response = await _dio.post(
      ApiEndpoints.twoFactorTotpRecovery,
      data: {'recovery_code': recoveryCode},
    );
    final data = _extractData(response);
    return data['verified'] as bool? ?? false;
  }

  // Handles both {success: true, data: {...}} and bare response formats
  Map<String, dynamic> _extractData(Response response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ParseException(message: 'Unexpected response format: ${body.runtimeType}');
    }
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }
}
