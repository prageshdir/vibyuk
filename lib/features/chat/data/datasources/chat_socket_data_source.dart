import 'package:rxdart/rxdart.dart';
import 'package:vibyuk/core/socket/socket_events.dart';
import 'package:vibyuk/core/socket/socket_service.dart';
import 'package:vibyuk/features/chat/data/models/chat_message_model.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/typing_event_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/user_presence_entity.dart';

abstract interface class ChatSocketDataSource {
  Stream<ChatMessageEntity> watchMessages(String conversationId);
  Stream<TypingEventEntity> watchTyping(String conversationId);
  Stream<UserPresenceEntity> watchPresence(String userId);
  void sendTypingStart(String conversationId);
  void sendTypingStop(String conversationId);
  void joinConversation(String conversationId);
  void leaveConversation(String conversationId);
  void markDelivered(String messageId, String conversationId);
  void markRead(String messageId, String conversationId);
}

class ChatSocketDataSourceImpl implements ChatSocketDataSource {
  ChatSocketDataSourceImpl(this._socket);
  final SocketService _socket;

  bool _matchesConv(dynamic data, String convId) =>
      (data as Map?)?['conversation_id'] == convId;

  @override
  Stream<ChatMessageEntity> watchMessages(String conversationId) =>
      _socket
          .on(SocketEvents.newMessage)
          .where((d) => _matchesConv(d, conversationId))
          .map((d) => ChatMessageModel.fromJson(
              Map<String, dynamic>.from(d as Map)).toEntity());

  @override
  Stream<TypingEventEntity> watchTyping(String conversationId) {
    final startStream = _socket
        .on(SocketEvents.typingStart)
        .where((d) => _matchesConv(d, conversationId))
        .map((d) => TypingEventEntity(
              userId: (d as Map)['user_id'] as String,
              conversationId: conversationId,
              isTyping: true,
              timestamp: DateTime.now(),
            ));

    final stopStream = _socket
        .on(SocketEvents.typingStop)
        .where((d) => _matchesConv(d, conversationId))
        .map((d) => TypingEventEntity(
              userId: (d as Map)['user_id'] as String,
              conversationId: conversationId,
              isTyping: false,
              timestamp: DateTime.now(),
            ));

    return MergeStream([startStream, stopStream]);
  }

  @override
  Stream<UserPresenceEntity> watchPresence(String userId) =>
      _socket
          .on(SocketEvents.presenceUpdate)
          .where((d) => (d as Map?)?['user_id'] == userId)
          .map((d) {
            final m = Map<String, dynamic>.from(d as Map);
            return UserPresenceEntity(
              userId: m['user_id'] as String,
              isOnline: m['is_online'] as bool? ?? false,
              lastSeen: m['last_seen'] != null
                  ? DateTime.parse(m['last_seen'] as String)
                  : null,
            );
          });

  @override
  void sendTypingStart(String conversationId) => _socket.emit(
      SocketEvents.typingStart, {'conversation_id': conversationId});

  @override
  void sendTypingStop(String conversationId) => _socket.emit(
      SocketEvents.typingStop, {'conversation_id': conversationId});

  @override
  void joinConversation(String conversationId) =>
      _socket.joinRoom('conversation:$conversationId');

  @override
  void leaveConversation(String conversationId) =>
      _socket.leaveRoom('conversation:$conversationId');

  @override
  void markDelivered(String messageId, String conversationId) =>
      _socket.emit(SocketEvents.messageDelivered, {
        'message_id': messageId,
        'conversation_id': conversationId,
      });

  @override
  void markRead(String messageId, String conversationId) =>
      _socket.emit(SocketEvents.messageRead, {
        'message_id': messageId,
        'conversation_id': conversationId,
      });
}
