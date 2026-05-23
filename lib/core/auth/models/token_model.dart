import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_model.freezed.dart';
part 'token_model.g.dart';

@freezed
class TokenModel with _$TokenModel {
  const TokenModel._();

  const factory TokenModel({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAt,
    @Default(false) bool rememberMe,
  }) = _TokenModel;

  factory TokenModel.fromJson(Map<String, dynamic> json) => _$TokenModelFromJson(json);

  bool get isAccessTokenExpired =>
      DateTime.now().isAfter(accessTokenExpiresAt.subtract(const Duration(minutes: 1)));

  bool get isAccessTokenValid => !isAccessTokenExpired;
}
