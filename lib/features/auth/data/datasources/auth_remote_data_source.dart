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
