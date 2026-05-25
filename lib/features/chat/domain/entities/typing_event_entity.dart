import 'package:equatable/equatable.dart';

class TypingEventEntity extends Equatable {
  const TypingEventEntity({
    required this.userId,
    required this.conversationId,
    required this.isTyping,
    required this.timestamp,
  });

  final String userId;
  final String conversationId;
  final bool isTyping;
  final DateTime timestamp;

  @override
  List<Object?> get props => [userId, conversationId, isTyping, timestamp];
}
