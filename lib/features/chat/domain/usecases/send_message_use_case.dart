import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase
    extends UseCase<ChatMessageEntity, SendMessageParams> {
  const SendMessageUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<Either<Failure, ChatMessageEntity>> call(SendMessageParams params) =>
      _repository.sendMessage(
        conversationId: params.conversationId,
        text: params.text,
      );
}

class SendMessageParams extends Equatable {
  const SendMessageParams({
    required this.conversationId,
    required this.text,
  });
  final String conversationId;
  final String text;

  @override
  List<Object?> get props => [conversationId, text];
}
