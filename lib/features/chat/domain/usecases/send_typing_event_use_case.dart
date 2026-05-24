import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class SendTypingStartUseCase {
  const SendTypingStartUseCase(this._repository);
  final ChatRepository _repository;

  void call(String conversationId) => _repository.sendTypingStart(conversationId);
}

class SendTypingStopUseCase {
  const SendTypingStopUseCase(this._repository);
  final ChatRepository _repository;

  void call(String conversationId) => _repository.sendTypingStop(conversationId);
}
