import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase
    extends UseCase<List<ChatMessageEntity>, GetMessagesParams> {
  const GetMessagesUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> call(
          GetMessagesParams params) =>
      _repository.getMessages(
          params.conversationId,
          page: params.page,
          pageSize: params.pageSize);
}

class GetMessagesParams extends Equatable {
  const GetMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.pageSize = 30,
  });
  final String conversationId;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [conversationId, page, pageSize];
}
