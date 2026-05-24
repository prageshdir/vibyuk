part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatState {
  const ChatInitialState();
}

class ChatLoadingState extends ChatState {
  const ChatLoadingState();
}

class ChatLoadedState extends ChatState {
  const ChatLoadedState({
    required this.messages,
    required this.conversationId,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isSending = false,
  });

  final List<ChatMessageEntity> messages;
  final String conversationId;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSending;

  ChatLoadedState copyWith({
    List<ChatMessageEntity>? messages,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSending,
  }) =>
      ChatLoadedState(
        messages: messages ?? this.messages,
        conversationId: conversationId,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isSending: isSending ?? this.isSending,
      );

  @override
  List<Object?> get props =>
      [messages, conversationId, hasMore, isLoadingMore, isSending];
}

class ChatErrorState extends ChatState {
  const ChatErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class ChatSendFailureState extends ChatLoadedState {
  const ChatSendFailureState({
    required super.messages,
    required super.conversationId,
    required this.failure,
  });
  final Failure failure;
  @override
  List<Object?> get props => [...super.props, failure];
}
