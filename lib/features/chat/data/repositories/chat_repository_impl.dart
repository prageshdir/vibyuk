import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:vibyuk/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:vibyuk/features/chat/data/datasources/chat_socket_data_source.dart';
import 'package:vibyuk/features/chat/data/models/chat_message_model.dart';
import 'package:vibyuk/features/chat/data/models/conversation_model.dart';
import 'package:vibyuk/features/chat/data/models/media_upload_model.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/media_upload_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/typing_event_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/user_presence_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl extends BaseRepository implements ChatRepository {
  ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    required ChatSocketDataSource socketDataSource,
    required ChatLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _socket = socketDataSource,
        _local = localDataSource;

  final ChatRemoteDataSource _remote;
  final ChatSocketDataSource _socket;
  final ChatLocalDataSource _local;

  // ── HTTP ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() =>
      safeCall(() async {
        try {
          final list = await _remote.getConversations();
          final entities =
              list.map((j) => ConversationModel.fromJson(j).toEntity()).toList();
          await _local.cacheConversations(entities);
          return entities;
        } catch (_) {
          return _local.getCachedConversations();
        }
      });

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(
          String conversationId,
          {int page = 1, int pageSize = 30}) =>
      safeCall(() async {
        if (page == 1) {
          final cached = await _local.getCachedMessages(conversationId);
          if (cached.isNotEmpty) return cached;
        }
        final list = await _remote.getMessages(conversationId,
            page: page, pageSize: pageSize);
        final entities =
            list.map((j) => ChatMessageModel.fromJson(j).toEntity()).toList();
        if (page == 1) await _local.cacheMessages(conversationId, entities);
        return entities;
      });

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String conversationId,
    required String text,
  }) =>
      safeCall(() async {
        final data =
            await _remote.sendMessage(conversationId: conversationId, text: text);
        final entity = ChatMessageModel.fromJson(data).toEntity();
        await _local.upsertMessage(conversationId, entity);
        return entity;
      });

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMediaMessage({
    required String conversationId,
    required MessageType type,
    required String mediaUrl,
    String? text,
    String? fileName,
    int? fileSize,
    int? durationSeconds,
  }) =>
      safeCall(() async {
        final data = await _remote.sendMediaMessage(
          conversationId: conversationId,
          type: type.name,
          mediaUrl: mediaUrl,
          text: text,
          fileName: fileName,
          fileSize: fileSize,
          durationSeconds: durationSeconds,
        );
        final entity = ChatMessageModel.fromJson(data).toEntity();
        await _local.upsertMessage(conversationId, entity);
        return entity;
      });

  @override
  Future<Either<Failure, MediaUploadEntity>> uploadMedia(File file) =>
      safeCall(() async {
        final data = await _remote.uploadMedia(file);
        return MediaUploadModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, void>> markConversationRead(
          String conversationId) =>
      safeCall(() => _remote.markConversationRead(conversationId));

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String otherUserId,
    String? bookingId,
  }) =>
      safeCall(() async {
        final data = await _remote.getOrCreateConversation(
            otherUserId: otherUserId, bookingId: bookingId);
        return ConversationModel.fromJson(data).toEntity();
      });

  // ── Real-time ─────────────────────────────────────────────────────────────

  @override
  Stream<ChatMessageEntity> watchMessages(String conversationId) =>
      _socket.watchMessages(conversationId);

  @override
  Stream<TypingEventEntity> watchTyping(String conversationId) =>
      _socket.watchTyping(conversationId);

  @override
  Stream<UserPresenceEntity> watchPresence(String userId) =>
      _socket.watchPresence(userId);

  @override
  void sendTypingStart(String conversationId) =>
      _socket.sendTypingStart(conversationId);

  @override
  void sendTypingStop(String conversationId) =>
      _socket.sendTypingStop(conversationId);

  @override
  void joinConversation(String conversationId) =>
      _socket.joinConversation(conversationId);

  @override
  void leaveConversation(String conversationId) =>
      _socket.leaveConversation(conversationId);

  @override
  void markDelivered(String messageId, String conversationId) =>
      _socket.markDelivered(messageId, conversationId);

  @override
  void markRead(String messageId, String conversationId) =>
      _socket.markRead(messageId, conversationId);
}
