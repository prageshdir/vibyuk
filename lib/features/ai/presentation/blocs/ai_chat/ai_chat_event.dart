import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

class InitializeChat extends AiChatEvent {
  final AiChatContext context;
  final String? existingConversationId;

  const InitializeChat({
    this.context = AiChatContext.general,
    this.existingConversationId,
  });

  @override
  List<Object?> get props => [context, existingConversationId];
}

class SendMessage extends AiChatEvent {
  final String content;
  final Map<String, dynamic>? attachedData;

  const SendMessage({required this.content, this.attachedData});

  @override
  List<Object?> get props => [content, attachedData];
}

class RetryFailedMessage extends AiChatEvent {
  final String messageId;

  const RetryFailedMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class ClearChat extends AiChatEvent {
  const ClearChat();
}

class LoadConversationHistory extends AiChatEvent {
  const LoadConversationHistory();
}

class SelectConversation extends AiChatEvent {
  final String conversationId;

  const SelectConversation({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}
