import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class GetOrCreateConversationUseCase
    extends UseCase<ConversationEntity, GetOrCreateConversationParams> {
  const GetOrCreateConversationUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<Either<Failure, ConversationEntity>> call(
          GetOrCreateConversationParams params) =>
      _repository.getOrCreateConversation(
        otherUserId: params.otherUserId,
        bookingId: params.bookingId,
      );
}

class GetOrCreateConversationParams extends Equatable {
  const GetOrCreateConversationParams({
    required this.otherUserId,
    this.bookingId,
  });
  final String otherUserId;
  final String? bookingId;

  @override
  List<Object?> get props => [otherUserId, bookingId];
}
