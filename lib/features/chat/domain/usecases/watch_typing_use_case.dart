import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/typing_event_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class WatchTypingUseCase implements StreamUseCase<TypingEventEntity, String> {
  const WatchTypingUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Stream<Either<Failure, TypingEventEntity>> call(String conversationId) =>
      _repository
          .watchTyping(conversationId)
          .map((t) => Right<Failure, TypingEventEntity>(t))
          .handleError(
              (_) => const Left<Failure, TypingEventEntity>(UnknownFailure()));
}
