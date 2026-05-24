import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/user_presence_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class WatchPresenceUseCase implements StreamUseCase<UserPresenceEntity, String> {
  const WatchPresenceUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Stream<Either<Failure, UserPresenceEntity>> call(String userId) =>
      _repository
          .watchPresence(userId)
          .map((p) => Right<Failure, UserPresenceEntity>(p))
          .handleError(
              (_) => const Left<Failure, UserPresenceEntity>(UnknownFailure()));
}
