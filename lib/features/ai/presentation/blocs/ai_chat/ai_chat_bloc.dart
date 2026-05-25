import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';
import 'package:vibyuk/features/ai/domain/usecases/send_ai_chat_message_usecase.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends BaseBloc<AiChatEvent, AiChatState> {
  final SendAiChatMessageUseCase _sendMessage;
  final CreateConversationUseCase _createConversation;
  final GetConversationHistoryUseCase _getHistory;
  final Uuid _uuid;

  AiChatBloc({
    required SendAiChatMessageUseCase sendMessage,
    required CreateConversationUseCase createConversation,
    required GetConversationHistoryUseCase getHistory,
  })  : _sendMessage = sendMessage,
        _createConversation = createConversation,
        _getHistory = getHistory,
        _uuid = const Uuid(),
        super(const AiChatState()) {
    on<InitializeChat>(_onInitialize);
    on<SendMessage>(_onSend);
    on<ClearChat>(_onClear);
    on<LoadConversationHistory>(_onLoadHistory);
    on<SelectConversation>(_onSelectConversation);
    on<RetryFailedMessage>(_onRetry);
  }

  Future<void> _onInitialize(
    InitializeChat event,
    Emitter<AiChatState> emit,
  ) async {
    emit(state.copyWith(
      status: AiChatStatus.initializing,
      chatContext: event.context,
    ));

    final result = await _createConversation(
      CreateConversationParams(context: event.context),
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(status: AiChatStatus.failure, failure: failure)),
      (conversation) => emit(state.copyWith(
        status: AiChatStatus.ready,
        activeConversation: conversation,
        failure: null,
      )),
    );
  }

  Future<void> _onSend(
    SendMessage event,
    Emitter<AiChatState> emit,
  ) async {
    if (state.activeConversation == null) return;

    final userMessage = AiChatMessage(
      id: _uuid.v4(),
      conversationId: state.activeConversation!.id,
      role: AiChatRole.user,
      content: event.content,
      timestamp: DateTime.now(),
      status: AiChatMessageStatus.sending,
      context: state.chatContext,
    );

    final updatedConversation = _appendMessage(
      state.activeConversation!,
      userMessage,
    );

    emit(state.copyWith(
      status: AiChatStatus.sending,
      activeConversation: updatedConversation,
      isTyping: true,
    ));

    final result = await _sendMessage(
      SendChatMessageParams(
        conversationId: state.activeConversation!.id,
        content: event.content,
        context: state.chatContext,
        attachedData: event.attachedData,
      ),
    );

    result.fold(
      (failure) {
        final failedConv = _updateMessageStatus(
          updatedConversation,
          userMessage.id,
          AiChatMessageStatus.failed,
        );
        emit(state.copyWith(
          status: AiChatStatus.failure,
          activeConversation: failedConv,
          isTyping: false,
          failure: failure,
        ));
      },
      (assistantMessage) {
        final sentConv = _updateMessageStatus(
          updatedConversation,
          userMessage.id,
          AiChatMessageStatus.sent,
        );
        final finalConv = _appendMessage(sentConv, assistantMessage);
        emit(state.copyWith(
          status: AiChatStatus.ready,
          activeConversation: finalConv,
          isTyping: false,
          failure: null,
        ));
      },
    );
  }

  Future<void> _onRetry(
    RetryFailedMessage event,
    Emitter<AiChatState> emit,
  ) async {
    if (state.activeConversation == null) return;
    final failedMsg = state.messages
        .where((m) => m.id == event.messageId)
        .firstOrNull;
    if (failedMsg == null) return;

    add(SendMessage(content: failedMsg.content));
  }

  void _onClear(ClearChat event, Emitter<AiChatState> emit) {
    emit(const AiChatState());
  }

  Future<void> _onLoadHistory(
    LoadConversationHistory event,
    Emitter<AiChatState> emit,
  ) async {
    final result = await _getHistory();
    result.fold(
      (_) {},
      (history) => emit(state.copyWith(conversationHistory: history)),
    );
  }

  void _onSelectConversation(
    SelectConversation event,
    Emitter<AiChatState> emit,
  ) {
    final conv = state.conversationHistory
        .where((c) => c.id == event.conversationId)
        .firstOrNull;
    if (conv != null) {
      emit(state.copyWith(
        activeConversation: conv,
        status: AiChatStatus.ready,
      ));
    }
  }

  AiConversation _appendMessage(AiConversation conv, AiChatMessage msg) {
    return AiConversation(
      id: conv.id,
      title: conv.title,
      context: conv.context,
      messages: [...conv.messages, msg],
      createdAt: conv.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  AiConversation _updateMessageStatus(
    AiConversation conv,
    String messageId,
    AiChatMessageStatus newStatus,
  ) {
    return AiConversation(
      id: conv.id,
      title: conv.title,
      context: conv.context,
      messages: conv.messages
          .map((m) => m.id == messageId ? m.copyWith(status: newStatus) : m)
          .toList(),
      createdAt: conv.createdAt,
      updatedAt: conv.updatedAt,
    );
  }
}
