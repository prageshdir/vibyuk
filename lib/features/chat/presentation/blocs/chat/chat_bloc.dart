import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/typing_event_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/user_presence_entity.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_messages_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/mark_conversation_read_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/send_media_message_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/send_typing_event_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/upload_media_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/watch_messages_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/watch_typing_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/watch_presence_use_case.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends BaseBloc<ChatEvent, ChatState> {
  ChatBloc({
    required GetMessagesUseCase getMessages,
    required SendMessageUseCase sendMessage,
    required SendMediaMessageUseCase sendMediaMessage,
    required UploadMediaUseCase uploadMedia,
    required WatchMessagesUseCase watchMessages,
    required WatchTypingUseCase watchTyping,
    required WatchPresenceUseCase watchPresence,
    required SendTypingStartUseCase sendTypingStart,
    required SendTypingStopUseCase sendTypingStop,
    required MarkConversationReadUseCase markRead,
  })  : _getMessages = getMessages,
        _sendMessage = sendMessage,
        _sendMediaMessage = sendMediaMessage,
        _uploadMedia = uploadMedia,
        _watchMessages = watchMessages,
        _watchTyping = watchTyping,
        _watchPresence = watchPresence,
        _sendTypingStart = sendTypingStart,
        _sendTypingStop = sendTypingStop,
        _markRead = markRead,
        super(const ChatInitialState()) {
    on<LoadMessagesEvent>(_onLoad);
    on<LoadMoreMessagesEvent>(_onLoadMore);
    on<SendTextMessageEvent>(_onSendText);
    on<SendImageEvent>(_onSendImage);
    on<SendFileEvent>(_onSendFile);
    on<SendAudioEvent>(_onSendAudio);
    on<StartTypingEvent>(_onStartTyping);
    on<StopTypingEvent>(_onStopTyping);
    on<_SocketMessageReceivedEvent>(_onSocketMessage);
    on<_SocketTypingChangedEvent>(_onSocketTyping);
    on<_SocketPresenceChangedEvent>(_onSocketPresence);
    on<MarkMessagesReadEvent>(_onMarkRead);
  }

  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  final SendMediaMessageUseCase _sendMediaMessage;
  final UploadMediaUseCase _uploadMedia;
  final WatchMessagesUseCase _watchMessages;
  final WatchTypingUseCase _watchTyping;
  final WatchPresenceUseCase _watchPresence;
  final SendTypingStartUseCase _sendTypingStart;
  final SendTypingStopUseCase _sendTypingStop;
  final MarkConversationReadUseCase _markRead;

  StreamSubscription<dynamic>? _msgSub;
  StreamSubscription<dynamic>? _typingSub;
  StreamSubscription<dynamic>? _presenceSub;
  Timer? _typingDebounce;

  Future<void> _onLoad(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(const ChatLoadingState());
    final result = await _getMessages(
        GetMessagesParams(conversationId: event.conversationId));
    result.fold(
      (f) => emit(ChatErrorState(failure: f)),
      (msgs) {
        emit(ChatLoadedState(
          messages: msgs,
          conversationId: event.conversationId,
          otherUserId: event.otherUserId,
          hasMore: msgs.length >= 20,
        ));
        _subscribeToSocket(event.conversationId, event.otherUserId);
        add(const MarkMessagesReadEvent());
      },
    );
  }

  Future<void> _onLoadMore(
      LoadMoreMessagesEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    if (!current.hasMore) return;
    final nextPage = current.currentPage + 1;
    final result = await _getMessages(GetMessagesParams(
      conversationId: current.conversationId,
      page: nextPage,
    ));
    result.fold(
      (_) {},
      (msgs) {
        emit(current.copyWith(
          messages: [...current.messages, ...msgs],
          hasMore: msgs.length >= 20,
          currentPage: nextPage,
        ));
      },
    );
  }

  Future<void> _onSendText(
      SendTextMessageEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessageEntity(
      id: tempId,
      conversationId: current.conversationId,
      senderId: 'me',
      senderName: 'Me',
      type: MessageType.text,
      text: event.text,
      status: MessageStatus.sending,
      isMe: true,
      createdAt: DateTime.now(),
    );
    emit(current.copyWith(messages: [optimistic, ...current.messages]));
    final result = await _sendMessage(SendMessageParams(
      conversationId: current.conversationId,
      text: event.text,
    ));
    result.fold(
      (f) {
        final loaded = state as ChatLoadedState;
        final updated = loaded.messages
            .map((m) => m.id == tempId
                ? ChatMessageEntity(
                    id: tempId,
                    conversationId: m.conversationId,
                    senderId: m.senderId,
                    senderName: m.senderName,
                    type: m.type,
                    text: m.text,
                    status: MessageStatus.failed,
                    isMe: true,
                    createdAt: m.createdAt,
                  )
                : m)
            .toList();
        emit(loaded.copyWith(messages: updated));
      },
      (msg) {
        final loaded = state as ChatLoadedState;
        final updated =
            loaded.messages.map((m) => m.id == tempId ? msg : m).toList();
        emit(loaded.copyWith(messages: updated));
      },
    );
  }

  Future<void> _onSendImage(
      SendImageEvent event, Emitter<ChatState> emit) async {
    await _uploadAndSend(
      file: event.file,
      type: MessageType.image,
      emit: emit,
    );
  }

  Future<void> _onSendFile(
      SendFileEvent event, Emitter<ChatState> emit) async {
    await _uploadAndSend(
      file: event.file,
      type: MessageType.file,
      emit: emit,
    );
  }

  Future<void> _onSendAudio(
      SendAudioEvent event, Emitter<ChatState> emit) async {
    await _uploadAndSend(
      file: event.file,
      type: MessageType.audio,
      durationSeconds: event.durationSeconds,
      emit: emit,
    );
  }

  Future<void> _uploadAndSend({
    required File file,
    required MessageType type,
    int? durationSeconds,
    required Emitter<ChatState> emit,
  }) async {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    emit(current.copyWith(uploadProgress: 0.1));

    final uploadResult = await _uploadMedia(file);
    if (uploadResult.isLeft()) {
      if (state is ChatLoadedState) {
        emit((state as ChatLoadedState).copyWith(clearUploadProgress: true));
      }
      return;
    }
    final media = uploadResult.getOrElse(() => throw StateError('unreachable'));

    emit((state as ChatLoadedState).copyWith(uploadProgress: 0.8));
    final sendResult = await _sendMediaMessage(SendMediaMessageParams(
      conversationId: current.conversationId,
      type: type,
      mediaUrl: media.url,
      fileName: media.fileName,
      fileSize: media.fileSize,
      durationSeconds: durationSeconds,
    ));
    sendResult.fold(
      (_) {
        if (state is ChatLoadedState) {
          emit((state as ChatLoadedState).copyWith(clearUploadProgress: true));
        }
      },
      (msg) {
        if (state is ChatLoadedState) {
          final loaded = state as ChatLoadedState;
          emit(loaded.copyWith(
            messages: [msg, ...loaded.messages],
            clearUploadProgress: true,
          ));
        }
      },
    );
  }

  void _onStartTyping(StartTypingEvent event, Emitter<ChatState> emit) {
    if (state is! ChatLoadedState) return;
    _sendTypingStart((state as ChatLoadedState).conversationId);
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 2500), () {
      add(const StopTypingEvent());
    });
  }

  void _onStopTyping(StopTypingEvent event, Emitter<ChatState> emit) {
    if (state is! ChatLoadedState) return;
    _typingDebounce?.cancel();
    _sendTypingStop((state as ChatLoadedState).conversationId);
  }

  void _onSocketMessage(
      _SocketMessageReceivedEvent event, Emitter<ChatState> emit) {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    final exists = current.messages.any((m) => m.id == event.message.id);
    if (!exists) {
      emit(current.copyWith(messages: [event.message, ...current.messages]));
      add(const MarkMessagesReadEvent());
    }
  }

  void _onSocketTyping(
      _SocketTypingChangedEvent event, Emitter<ChatState> emit) {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    if (event.event.userId != current.otherUserId) return;
    emit(current.copyWith(isOtherUserTyping: event.event.isTyping));
  }

  void _onSocketPresence(
      _SocketPresenceChangedEvent event, Emitter<ChatState> emit) {
    if (state is! ChatLoadedState) return;
    final current = state as ChatLoadedState;
    if (event.presence.userId != current.otherUserId) return;
    emit(current.copyWith(
      isOtherUserOnline: event.presence.isOnline,
      otherUserLastSeen: event.presence.lastSeen,
    ));
  }

  Future<void> _onMarkRead(
      MarkMessagesReadEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoadedState) return;
    await _markRead((state as ChatLoadedState).conversationId);
  }

  void _subscribeToSocket(String conversationId, String otherUserId) {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _presenceSub?.cancel();

    // StreamUseCase returns Stream<Either<Failure, T>> — we fold each event
    _msgSub = _watchMessages(conversationId).listen(
      (either) => either.fold(
        (_) {}, // ignore stream errors silently
        (msg) => add(_SocketMessageReceivedEvent(msg)),
      ),
    );
    _typingSub = _watchTyping(conversationId).listen(
      (either) => either.fold(
        (_) {},
        (e) => add(_SocketTypingChangedEvent(e)),
      ),
    );
    _presenceSub = _watchPresence(otherUserId).listen(
      (either) => either.fold(
        (_) {},
        (p) => add(_SocketPresenceChangedEvent(p)),
      ),
    );
  }

  @override
  Future<void> close() {
    _typingDebounce?.cancel();
    _msgSub?.cancel();
    _typingSub?.cancel();
    _presenceSub?.cancel();
    return super.close();
  }
}
