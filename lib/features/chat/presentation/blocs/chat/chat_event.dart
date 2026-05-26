part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class LoadMessagesEvent extends ChatEvent {
  const LoadMessagesEvent({required this.conversationId, required this.otherUserId});
  final String conversationId;
  final String otherUserId;
  @override
  List<Object?> get props => [conversationId, otherUserId];
}

class LoadMoreMessagesEvent extends ChatEvent {
  const LoadMoreMessagesEvent();
  @override
  List<Object?> get props => [];
}

class SendTextMessageEvent extends ChatEvent {
  const SendTextMessageEvent(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

class SendImageEvent extends ChatEvent {
  const SendImageEvent(this.file);
  final File file;
  @override
  List<Object?> get props => [file.path];
}

class SendFileEvent extends ChatEvent {
  const SendFileEvent(this.file);
  final File file;
  @override
  List<Object?> get props => [file.path];
}

class SendAudioEvent extends ChatEvent {
  const SendAudioEvent({required this.file, required this.durationSeconds});
  final File file;
  final int durationSeconds;
  @override
  List<Object?> get props => [file.path, durationSeconds];
}

class StartTypingEvent extends ChatEvent {
  const StartTypingEvent();
  @override
  List<Object?> get props => [];
}

class StopTypingEvent extends ChatEvent {
  const StopTypingEvent();
  @override
  List<Object?> get props => [];
}

class _SocketMessageReceivedEvent extends ChatEvent {
  const _SocketMessageReceivedEvent(this.message);
  final ChatMessageEntity message;
  @override
  List<Object?> get props => [message];
}

class _SocketTypingChangedEvent extends ChatEvent {
  const _SocketTypingChangedEvent(this.event);
  final TypingEventEntity event;
  @override
  List<Object?> get props => [event];
}

class _SocketPresenceChangedEvent extends ChatEvent {
  const _SocketPresenceChangedEvent(this.presence);
  final UserPresenceEntity presence;
  @override
  List<Object?> get props => [presence];
}

class MarkMessagesReadEvent extends ChatEvent {
  const MarkMessagesReadEvent();
  @override
  List<Object?> get props => [];
}
