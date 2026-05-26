import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';

class AuthSessionEntity extends Equatable {
  final UserEntity user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final bool rememberMe;

  const AuthSessionEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.rememberMe = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
        user,
        accessToken,
        refreshToken,
        expiresAt,
        rememberMe,
      ];
}
