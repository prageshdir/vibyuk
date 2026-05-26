import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';

class RoleSelectionDto {
  final UserRole role;

  const RoleSelectionDto({required this.role});

  Map<String, dynamic> toJson() => {'role': role.serverValue};
}
