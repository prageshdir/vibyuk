import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(
      String conversationId, {int page = 1, int pageSize = 30});

  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String conversationId,
    required String text,
  });

  Future<Either<Failure, void>> markConversationRead(String conversationId);

  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String otherUserId,
    String? bookingId,
  });
}
