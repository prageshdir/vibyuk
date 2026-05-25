import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';

enum AiChatStatus { initial, initializing, ready, sending, failure }

class AiChatState extends Equatable {
  final AiChatStatus status;
  final AiConversation? activeConversation;
  final List<AiConversation> conversationHistory;
  final bool isTyping;
  final Failure? failure;
  final AiChatContext chatContext;

  const AiChatState({
    this.status = AiChatStatus.initial,
    this.activeConversation,
    this.conversationHistory = const [],
    this.isTyping = false,
    this.failure,
    this.chatContext = AiChatContext.general,
  });

  List<AiChatMessage> get messages =>
      activeConversation?.messages ?? const [];

  bool get isReady => status == AiChatStatus.ready;
  bool get isSending => status == AiChatStatus.sending;
  bool get hasError => status == AiChatStatus.failure;
  bool get hasConversation => activeConversation != null;

  AiChatState copyWith({
    AiChatStatus? status,
    AiConversation? activeConversation,
    List<AiConversation>? conversationHistory,
    bool? isTyping,
    Failure? failure,
    AiChatContext? chatContext,
  }) {
    return AiChatState(
      status: status ?? this.status,
      activeConversation: activeConversation ?? this.activeConversation,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      isTyping: isTyping ?? this.isTyping,
      failure: failure ?? this.failure,
      chatContext: chatContext ?? this.chatContext,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeConversation,
        conversationHistory,
        isTyping,
        failure,
        chatContext,
      ];
}
