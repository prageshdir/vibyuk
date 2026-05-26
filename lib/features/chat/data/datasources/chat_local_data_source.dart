import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:vibyuk/core/cache/hive/hive_service.dart';
import 'package:vibyuk/features/chat/data/models/chat_message_model.dart';
import 'package:vibyuk/features/chat/data/models/conversation_model.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';

abstract final class _ChatBoxNames {
  static const String conversations = 'chat_conversations';
  static const String offlineQueue = 'chat_offline_queue';
  static String messages(String convId) => 'chat_msg_$convId';
}

abstract interface class ChatLocalDataSource {
  Future<List<ConversationEntity>> getCachedConversations();
  Future<void> cacheConversations(List<ConversationEntity> conversations);
  Future<List<ChatMessageEntity>> getCachedMessages(String conversationId);
  Future<void> cacheMessages(
      String conversationId, List<ChatMessageEntity> messages);
  Future<void> upsertMessage(
      String conversationId, ChatMessageEntity message);
  Future<List<ChatMessageEntity>> getOfflineQueue();
  Future<void> addToOfflineQueue(ChatMessageEntity message);
  Future<void> removeFromOfflineQueue(String tempId);
  Future<void> clearAll();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  Box<String>? _convBox;
  final Map<String, Box<String>> _msgBoxes = {};
  Box<String>? _queueBox;

  Future<Box<String>> get _convBoxAsync async =>
      _convBox ??=
          await HiveService.openBox<String>(_ChatBoxNames.conversations);

  Future<Box<String>> _msgBox(String convId) async {
    final key = _ChatBoxNames.messages(convId);
    return _msgBoxes[key] ??= await HiveService.openBox<String>(key);
  }

  Future<Box<String>> get _queueBoxAsync async =>
      _queueBox ??=
          await HiveService.openBox<String>(_ChatBoxNames.offlineQueue);

  @override
  Future<List<ConversationEntity>> getCachedConversations() async {
    final box = await _convBoxAsync;
    final raw = box.get('list');
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((j) =>
            ConversationModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<void> cacheConversations(
      List<ConversationEntity> conversations) async {
    final box = await _convBoxAsync;
    await box.put('list',
        jsonEncode(conversations.map(_convToJson).toList()));
  }

  @override
  Future<List<ChatMessageEntity>> getCachedMessages(
      String conversationId) async {
    final box = await _msgBox(conversationId);
    final raw = box.get('messages');
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((j) =>
            ChatMessageModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<void> cacheMessages(
      String conversationId, List<ChatMessageEntity> messages) async {
    final box = await _msgBox(conversationId);
    await box.put('messages',
        jsonEncode(messages.map(_msgToJson).toList()));
  }

  @override
  Future<void> upsertMessage(
      String conversationId, ChatMessageEntity message) async {
    final existing = await getCachedMessages(conversationId);
    final idx = existing.indexWhere((m) => m.id == message.id);
    if (idx >= 0) {
      existing[idx] = message;
    } else {
      existing.insert(0, message);
    }
    await cacheMessages(conversationId, existing);
  }

  @override
  Future<List<ChatMessageEntity>> getOfflineQueue() async {
    final box = await _queueBoxAsync;
    final raw = box.get('queue');
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((j) =>
            ChatMessageModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<void> addToOfflineQueue(ChatMessageEntity message) async {
    final queue = await getOfflineQueue();
    queue.add(message);
    final box = await _queueBoxAsync;
    await box.put(
        'queue', jsonEncode(queue.map(_msgToJson).toList()));
  }

  @override
  Future<void> removeFromOfflineQueue(String tempId) async {
    final queue = await getOfflineQueue();
    queue.removeWhere((m) => m.id == tempId);
    final box = await _queueBoxAsync;
    await box.put(
        'queue', jsonEncode(queue.map(_msgToJson).toList()));
  }

  @override
  Future<void> clearAll() async {
    (await _convBoxAsync).clear();
    (await _queueBoxAsync).clear();
    for (final b in _msgBoxes.values) {
      b.clear();
    }
  }

  Map<String, dynamic> _convToJson(ConversationEntity c) => {
        'id': c.id,
        'other_user_id': c.otherUserId,
        'other_user_name': c.otherUserName,
        'other_user_avatar_url': c.otherUserAvatarUrl,
        'other_user_role': c.otherUserRole.name,
        'last_message': c.lastMessage,
        'last_message_at': c.lastMessageAt?.toIso8601String(),
        'unread_count': c.unreadCount,
        'is_online': c.isOnline,
        'booking_id': c.bookingId,
        'campaign_id': c.campaignId,
        'created_at': c.createdAt.toIso8601String(),
      };

  Map<String, dynamic> _msgToJson(ChatMessageEntity m) => {
        'id': m.id,
        'conversation_id': m.conversationId,
        'sender_id': m.senderId,
        'sender_name': m.senderName,
        'sender_avatar_url': m.senderAvatarUrl,
        'type': m.type.name,
        'text': m.text,
        'media_url': m.mediaUrl,
        'file_name': m.fileName,
        'file_size': m.fileSize,
        'duration_seconds': m.durationSeconds,
        'booking_id': m.bookingId,
        'status': m.status.name,
        'is_me': m.isMe,
        'created_at': m.createdAt.toIso8601String(),
        'edited_at': m.editedAt?.toIso8601String(),
      };
}
