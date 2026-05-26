import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_conversations_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/mark_conversation_read_use_case.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

class ConversationsBloc
    extends BaseBloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc({
    required GetConversationsUseCase getConversations,
    required MarkConversationReadUseCase markRead,
  })  : _getConversations = getConversations,
        _markRead = markRead,
        super(const ConversationsInitialState()) {
    on<LoadConversationsEvent>(_onLoad);
    on<RefreshConversationsEvent>(_onRefresh);
    on<ConversationReadEvent>(_onMarkRead);
  }

  final GetConversationsUseCase _getConversations;
  final MarkConversationReadUseCase _markRead;

  Future<void> _onLoad(
      LoadConversationsEvent event, Emitter<ConversationsState> emit) async {
    emit(const ConversationsLoadingState());
    final result = await _getConversations();
    result.fold(
      (f) => emit(ConversationsErrorState(failure: f)),
      (list) => emit(ConversationsLoadedState(conversations: list)),
    );
  }

  Future<void> _onRefresh(
      RefreshConversationsEvent event, Emitter<ConversationsState> emit) async {
    add(const LoadConversationsEvent());
  }

  Future<void> _onMarkRead(
      ConversationReadEvent event, Emitter<ConversationsState> emit) async {
    await _markRead(event.conversationId);
    if (state is ConversationsLoadedState) {
      final current = state as ConversationsLoadedState;
      final updated = current.conversations.map((c) {
        if (c.id == event.conversationId) {
          return ConversationEntity(
            id: c.id,
            otherUserId: c.otherUserId,
            otherUserName: c.otherUserName,
            otherUserAvatarUrl: c.otherUserAvatarUrl,
            otherUserRole: c.otherUserRole,
            lastMessage: c.lastMessage,
            lastMessageAt: c.lastMessageAt,
            unreadCount: 0,
            isOnline: c.isOnline,
            bookingId: c.bookingId,
            campaignId: c.campaignId,
            createdAt: c.createdAt,
          );
        }
        return c;
      }).toList();
      emit(current.copyWith(conversations: updated));
    }
  }
}
