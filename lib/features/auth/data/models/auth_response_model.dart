import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/core/auth/models/token_model.dart';
import 'package:vibyuk/features/auth/data/models/user_model.dart';
import 'package:vibyuk/features/auth/domain/entities/auth_session_entity.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

@freezed
class AuthResponseModel with _$AuthResponseModel {
  const AuthResponseModel._();

  const factory AuthResponseModel({
    required UserModel user,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_in') @Default(3600) int expiresIn,
    @JsonKey(name: 'token_type') @Default('Bearer') String tokenType,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  TokenModel toTokenModel({bool rememberMe = false}) => TokenModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
        rememberMe: rememberMe,
      );

  AuthSessionEntity toEntity({bool rememberMe = false}) => AuthSessionEntity(
        user: user.toEntity(),
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
        rememberMe: rememberMe,
      );
}
