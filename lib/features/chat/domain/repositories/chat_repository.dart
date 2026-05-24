import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/media_upload_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/typing_event_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/user_presence_entity.dart';

abstract interface class ChatRepository {
  // ── HTTP ──────────────────────────────────────────────────────────────────
  Future<Either<Failure, List<ConversationEntity>>> getConversations();
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(
      String conversationId, {int page = 1, int pageSize = 30});
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String conversationId,
    required String text,
  });
  Future<Either<Failure, ChatMessageEntity>> sendMediaMessage({
    required String conversationId,
    required MessageType type,
    required String mediaUrl,
    String? text,
    String? fileName,
    int? fileSize,
    int? durationSeconds,
  });
  Future<Either<Failure, MediaUploadEntity>> uploadMedia(File file);
  Future<Either<Failure, void>> markConversationRead(String conversationId);
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String otherUserId,
    String? bookingId,
  });

  // ── Real-time (Socket) ────────────────────────────────────────────────────
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
