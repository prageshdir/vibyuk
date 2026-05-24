part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends ChatEvent {
  const LoadMessagesEvent({required this.conversationId});
  final String conversationId;
  @override
  List<Object?> get props => [conversationId];
}

class LoadMoreMessagesEvent extends ChatEvent {
  const LoadMoreMessagesEvent();
}

class SendMessageEvent extends ChatEvent {
  const SendMessageEvent({required this.text});
  final String text;
  @override
  List<Object?> get props => [text];
}

class MessageSentEvent extends ChatEvent {
  const MessageSentEvent({required this.message});
  final ChatMessageEntity message;
  @override
  List<Object?> get props => [message];
}
