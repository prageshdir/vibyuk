import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    String? phone,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? role,
    @JsonKey(name: 'is_email_verified') @Default(false) bool isEmailVerified,
    @JsonKey(name: 'is_phone_verified') @Default(false) bool isPhoneVerified,
    @JsonKey(name: 'is_biometric_enabled') @Default(false) bool isBiometricEnabled,
    @JsonKey(name: 'is_two_factor_enabled') @Default(false) bool isTwoFactorEnabled,
    @JsonKey(name: 'two_factor_method') String? twoFactorMethod,
    @JsonKey(name: 'is_suspended') @Default(false) bool isSuspended,
    @JsonKey(name: 'suspension_reason') String? suspensionReason,
    @JsonKey(name: 'suspended_at') DateTime? suspendedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
        role: UserRole.fromString(role),
        isEmailVerified: isEmailVerified,
        isPhoneVerified: isPhoneVerified,
        isBiometricEnabled: isBiometricEnabled,
        isTwoFactorEnabled: isTwoFactorEnabled,
        twoFactorMethod: TwoFactorMethod.fromString(twoFactorMethod),
        isSuspended: isSuspended,
        suspensionReason: suspensionReason,
        suspendedAt: suspendedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
