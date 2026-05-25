import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';
import 'package:vibyuk/features/ai/domain/repositories/ai_repository.dart';

class SendAiChatMessageUseCase
    implements UseCase<AiChatMessage, SendChatMessageParams> {
  final AiRepository _repository;

  const SendAiChatMessageUseCase(this._repository);

  @override
  Future<Either<Failure, AiChatMessage>> call(SendChatMessageParams params) {
    return _repository.sendChatMessage(
      conversationId: params.conversationId,
      content: params.content,
      context: params.context,
      attachedData: params.attachedData,
    );
  }
}

class CreateConversationUseCase
    implements UseCase<AiConversation, CreateConversationParams> {
  final AiRepository _repository;

  const CreateConversationUseCase(this._repository);

  @override
  Future<Either<Failure, AiConversation>> call(CreateConversationParams params) {
    return _repository.createConversation(
      context: params.context,
      title: params.title,
    );
  }
}

class GetConversationHistoryUseCase
    implements NoParamUseCase<List<AiConversation>> {
  final AiRepository _repository;

  const GetConversationHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<AiConversation>>> call() {
    return _repository.getConversationHistory();
  }
}

class SendChatMessageParams extends Equatable {
  final String conversationId;
  final String content;
  final AiChatContext context;
  final Map<String, dynamic>? attachedData;

  const SendChatMessageParams({
    required this.conversationId,
    required this.content,
    this.context = AiChatContext.general,
    this.attachedData,
  });

  @override
  List<Object?> get props => [conversationId, content, context, attachedData];
}

class CreateConversationParams extends Equatable {
  final AiChatContext context;
  final String? title;

  const CreateConversationParams({
    this.context = AiChatContext.general,
    this.title,
  });

  @override
  List<Object?> get props => [context, title];
}
