part of 'negotiation_bloc.dart';

sealed class NegotiationState extends Equatable {
  const NegotiationState();
}

class NegotiationInitialState extends NegotiationState {
  const NegotiationInitialState();
  @override
  List<Object?> get props => [];
}

class NegotiationLoadingState extends NegotiationState {
  const NegotiationLoadingState();
  @override
  List<Object?> get props => [];
}

class NegotiationLoadedState extends NegotiationState {
  const NegotiationLoadedState({
    required this.messages,
    this.isSending = false,
    this.sendError,
  });

  final List<BookingNegotiationMessageEntity> messages;
  final bool isSending;
  final Failure? sendError;

  NegotiationLoadedState copyWith({
    List<BookingNegotiationMessageEntity>? messages,
    bool? isSending,
    Failure? sendError,
  }) =>
      NegotiationLoadedState(
        messages: messages ?? this.messages,
        isSending: isSending ?? false,
        sendError: sendError,
      );

  @override
  List<Object?> get props => [messages, isSending, sendError];
}

class NegotiationErrorState extends NegotiationState {
  const NegotiationErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
