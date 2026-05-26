import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class GetConversationsUseCase
    extends NoParamUseCase<List<ConversationEntity>> {
  const GetConversationsUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<Either<Failure, List<ConversationEntity>>> call() =>
      _repository.getConversations();
}
