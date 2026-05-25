import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';

class AiChatMessageModel extends AiChatMessage {
  const AiChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.role,
    required super.content,
    required super.timestamp,
    super.status,
    super.context,
    super.attachedData,
  });

  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) {
    return AiChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: AiChatRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => AiChatRole.user,
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: AiChatMessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AiChatMessageStatus.sent,
      ),
      context: AiChatContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => AiChatContext.general,
      ),
      attachedData: json['attached_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'context': context.name,
        'attached_data': attachedData,
      };
}

class AiConversationModel extends AiConversation {
  const AiConversationModel({
    required super.id,
    required super.title,
    required super.context,
    required super.messages,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AiConversationModel.fromJson(Map<String, dynamic> json) {
    return AiConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      context: AiChatContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => AiChatContext.general,
      ),
      messages: (json['messages'] as List? ?? [])
          .map((m) =>
              AiChatMessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
