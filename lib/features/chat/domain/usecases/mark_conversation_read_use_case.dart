import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class MarkConversationReadUseCase extends UseCase<void, String> {
  const MarkConversationReadUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<Either<Failure, void>> call(String conversationId) =>
      _repository.markConversationRead(conversationId);
}
