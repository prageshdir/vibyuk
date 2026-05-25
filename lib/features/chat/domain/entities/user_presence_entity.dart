import 'package:equatable/equatable.dart';

class UserPresenceEntity extends Equatable {
  const UserPresenceEntity({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
  });

  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;

  @override
  List<Object?> get props => [userId, isOnline, lastSeen];
}
