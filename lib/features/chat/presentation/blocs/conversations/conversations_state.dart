part of 'conversations_bloc.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();
  @override
  List<Object?> get props => [];
}

class ConversationsInitialState extends ConversationsState {
  const ConversationsInitialState();
}

class ConversationsLoadingState extends ConversationsState {
  const ConversationsLoadingState();
}

class ConversationsLoadedState extends ConversationsState {
  const ConversationsLoadedState({required this.conversations});
  final List<ConversationEntity> conversations;

  ConversationsLoadedState copyWith({
    List<ConversationEntity>? conversations,
  }) =>
      ConversationsLoadedState(
          conversations: conversations ?? this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationsErrorState extends ConversationsState {
  const ConversationsErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
