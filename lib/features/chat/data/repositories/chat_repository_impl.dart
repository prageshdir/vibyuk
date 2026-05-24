import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:vibyuk/features/chat/data/models/chat_message_model.dart';
import 'package:vibyuk/features/chat/data/models/conversation_model.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl extends BaseRepository implements ChatRepository {
  ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final ChatRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() =>
      safeCall(() async {
        final list = await _remote.getConversations();
        return list
            .map((j) => ConversationModel.fromJson(j).toEntity())
            .toList();
      });

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(
      String conversationId, {int page = 1, int pageSize = 30}) =>
      safeCall(() async {
        final list = await _remote.getMessages(
            conversationId, page: page, pageSize: pageSize);
        return list
            .map((j) => ChatMessageModel.fromJson(j).toEntity())
            .toList();
      });

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String conversationId,
    required String text,
  }) =>
      safeCall(() async {
        final data = await _remote.sendMessage(
            conversationId: conversationId, text: text);
        return ChatMessageModel.fromJson(data).toEntity();
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
}
