import 'package:equatable/equatable.dart';

enum UserRole {
  creator,
  business;

  String get displayName => switch (this) {
        UserRole.creator => 'Creator',
        UserRole.business => 'Business',
      };

  String get serverValue => name;

  static UserRole? fromString(String? value) {
    if (value == null) return null;
    return UserRole.values.where((r) => r.serverValue == value).firstOrNull;
  }
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String? lastName;
  final String? avatarUrl;
  final UserRole? role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isBiometricEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    this.lastName,
    this.avatarUrl,
    this.role,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isBiometricEnabled = false,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName =>
      lastName != null ? '$firstName $lastName' : firstName;

  bool get hasRole => role != null;

  bool get isProfileComplete => hasRole && isEmailVerified;

  UserEntity copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isBiometricEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        firstName,
        lastName,
        avatarUrl,
        role,
        isEmailVerified,
        isPhoneVerified,
        isBiometricEnabled,
        createdAt,
        updatedAt,
      ];
}
