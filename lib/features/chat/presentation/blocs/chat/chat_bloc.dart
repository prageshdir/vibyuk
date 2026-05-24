import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_messages_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/send_message_use_case.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends BaseBloc<ChatEvent, ChatState> {
  ChatBloc({
    required GetMessagesUseCase getMessages,
    required SendMessageUseCase sendMessage,
  })  : _getMessages = getMessages,
        _sendMessage = sendMessage,
        super(const ChatInitialState()) {
    on<LoadMessagesEvent>(_onLoad);
    on<LoadMoreMessagesEvent>(_onLoadMore);
    on<SendMessageEvent>(_onSend);
    on<MessageSentEvent>(_onMessageSent);
  }

  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  String _conversationId = '';
  int _currentPage = 1;
  static const int _pageSize = 30;

  Future<void> _onLoad(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    _conversationId = event.conversationId;
    _currentPage = 1;
    emit(const ChatLoadingState());
    final result = await _getMessages(GetMessagesParams(
      conversationId: _conversationId,
      page: _currentPage,
      pageSize: _pageSize,
    ));
    result.fold(
      (f) => emit(ChatErrorState(failure: f)),
      (messages) => emit(ChatLoadedState(
        messages: messages,
        conversationId: _conversationId,
        hasMore: messages.length == _pageSize,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMoreMessagesEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getMessages(GetMessagesParams(
      conversationId: _conversationId,
      page: _currentPage + 1,
      pageSize: _pageSize,
    ));
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (more) {
        _currentPage++;
        emit(current.copyWith(
          messages: [...current.messages, ...more],
          hasMore: more.length == _pageSize,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onSend(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    emit(current.copyWith(isSending: true));
    final result = await _sendMessage(SendMessageParams(
      conversationId: _conversationId,
      text: event.text,
    ));
    result.fold(
      (f) => emit(ChatSendFailureState(
          messages: current.messages,
          conversationId: _conversationId,
          failure: f)),
      (message) => emit(current.copyWith(
        messages: [message, ...current.messages],
        isSending: false,
      )),
    );
  }

  Future<void> _onMessageSent(
      MessageSentEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    final exists = current.messages.any((m) => m.id == event.message.id);
    if (!exists) {
      emit(current.copyWith(
          messages: [event.message, ...current.messages]));
    }
  }
}
