part of 'conversations_bloc.dart';

abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversationsEvent extends ConversationsEvent {
  const LoadConversationsEvent();
}

class RefreshConversationsEvent extends ConversationsEvent {
  const RefreshConversationsEvent();
}

class ConversationReadEvent extends ConversationsEvent {
  const ConversationReadEvent(this.conversationId);
  final String conversationId;
  @override
  List<Object?> get props => [conversationId];
}
