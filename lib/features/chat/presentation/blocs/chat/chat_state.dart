part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();
}

class ChatInitialState extends ChatState {
  const ChatInitialState();
  @override
  List<Object?> get props => [];
}

class ChatLoadingState extends ChatState {
  const ChatLoadingState();
  @override
  List<Object?> get props => [];
}

class ChatLoadedState extends ChatState {
  const ChatLoadedState({
    required this.messages,
    required this.conversationId,
    required this.otherUserId,
    this.isOtherUserTyping = false,
    this.isOtherUserOnline = false,
    this.otherUserLastSeen,
    this.uploadProgress,
    this.hasMore = true,
    this.currentPage = 1,
  });

  final List<ChatMessageEntity> messages;
  final String conversationId;
  final String otherUserId;
  final bool isOtherUserTyping;
  final bool isOtherUserOnline;
  final DateTime? otherUserLastSeen;
  final double? uploadProgress;
  final bool hasMore;
  final int currentPage;

  ChatLoadedState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isOtherUserTyping,
    bool? isOtherUserOnline,
    DateTime? otherUserLastSeen,
    double? uploadProgress,
    bool clearUploadProgress = false,
    bool? hasMore,
    int? currentPage,
  }) {
    return ChatLoadedState(
      messages: messages ?? this.messages,
      conversationId: conversationId,
      otherUserId: otherUserId,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
      isOtherUserOnline: isOtherUserOnline ?? this.isOtherUserOnline,
      otherUserLastSeen: otherUserLastSeen ?? this.otherUserLastSeen,
      uploadProgress:
          clearUploadProgress ? null : (uploadProgress ?? this.uploadProgress),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        conversationId,
        otherUserId,
        isOtherUserTyping,
        isOtherUserOnline,
        otherUserLastSeen,
        uploadProgress,
        hasMore,
        currentPage,
      ];
}

class ChatErrorState extends ChatState {
  const ChatErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
