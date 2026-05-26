import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class SendMediaMessageUseCase
    implements UseCase<ChatMessageEntity, SendMediaMessageParams> {
  const SendMediaMessageUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<Either<Failure, ChatMessageEntity>> call(
          SendMediaMessageParams params) =>
      _repository.sendMediaMessage(
        conversationId: params.conversationId,
        type: params.type,
        mediaUrl: params.mediaUrl,
        text: params.text,
        fileName: params.fileName,
        fileSize: params.fileSize,
        durationSeconds: params.durationSeconds,
      );
}

class SendMediaMessageParams extends Equatable {
  const SendMediaMessageParams({
    required this.conversationId,
    required this.type,
    required this.mediaUrl,
    this.text,
    this.fileName,
    this.fileSize,
    this.durationSeconds,
  });

  final String conversationId;
  final MessageType type;
  final String mediaUrl;
  final String? text;
  final String? fileName;
  final int? fileSize;
  final int? durationSeconds;

  @override
  List<Object?> get props => [
        conversationId, type, mediaUrl, text, fileName, fileSize, durationSeconds
      ];
}
