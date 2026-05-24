import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:vibyuk/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_conversations_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_messages_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_or_create_conversation_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/mark_conversation_read_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:vibyuk/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:vibyuk/features/chat/presentation/blocs/conversations/conversations_bloc.dart';

void registerChatModule(GetIt sl) {
  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(sl<Dio>()));

  // ── Repository ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl()));

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkConversationReadUseCase(sl()));
  sl.registerLazySingleton(() => GetOrCreateConversationUseCase(sl()));

  // ── BLoCs (factory — one per route) ──────────────────────────────────────
  sl.registerFactory(() => ConversationsBloc(
        getConversations: sl(),
        markRead: sl(),
      ));

  sl.registerFactory(() => ChatBloc(
        getMessages: sl(),
        sendMessage: sl(),
      ));
}
