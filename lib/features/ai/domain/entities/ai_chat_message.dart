import 'package:equatable/equatable.dart';

enum AiChatRole { user, assistant }
enum AiChatMessageStatus { sending, sent, failed }
enum AiChatContext { general, recommendations, campaign, pricing, analytics }

class AiChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final AiChatRole role;
  final String content;
  final DateTime timestamp;
  final AiChatMessageStatus status;
  final AiChatContext context;
  final Map<String, dynamic>? attachedData;

  const AiChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.status = AiChatMessageStatus.sent,
    this.context = AiChatContext.general,
    this.attachedData,
  });

  bool get isFromUser => role == AiChatRole.user;
  bool get isSending => status == AiChatMessageStatus.sending;
  bool get hasFailed => status == AiChatMessageStatus.failed;

  AiChatMessage copyWith({
    String? id,
    String? conversationId,
    AiChatRole? role,
    String? content,
    DateTime? timestamp,
    AiChatMessageStatus? status,
    AiChatContext? context,
    Map<String, dynamic>? attachedData,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      context: context ?? this.context,
      attachedData: attachedData ?? this.attachedData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        role,
        content,
        timestamp,
        status,
        context,
        attachedData,
      ];
}

class AiConversation extends Equatable {
  final String id;
  final String title;
  final AiChatContext context;
  final List<AiChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiConversation({
    required this.id,
    required this.title,
    required this.context,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  AiChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  @override
  List<Object?> get props => [id, title, context, messages, createdAt, updatedAt];
}
