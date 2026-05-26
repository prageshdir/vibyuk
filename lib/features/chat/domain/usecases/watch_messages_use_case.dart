import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class WatchMessagesUseCase
    implements StreamUseCase<ChatMessageEntity, String> {
  const WatchMessagesUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Stream<Either<Failure, ChatMessageEntity>> call(String conversationId) =>
      _repository
          .watchMessages(conversationId)
          .map((m) => Right<Failure, ChatMessageEntity>(m))
          .handleError(
              (_) => const Left<Failure, ChatMessageEntity>(UnknownFailure()));
}
