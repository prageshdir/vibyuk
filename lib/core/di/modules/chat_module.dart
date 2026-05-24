import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/socket/socket_service.dart';
import 'package:vibyuk/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:vibyuk/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:vibyuk/features/chat/data/datasources/chat_socket_data_source.dart';
import 'package:vibyuk/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:vibyuk/features/chat/data/services/chat_notification_service.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_conversations_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_messages_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/get_or_create_conversation_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/mark_conversation_read_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/send_media_message_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/send_typing_event_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/upload_media_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/watch_messages_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/watch_presence_use_case.dart';
import 'package:vibyuk/features/chat/domain/usecases/watch_typing_use_case.dart';
import 'package:vibyuk/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:vibyuk/features/chat/presentation/blocs/conversations/conversations_bloc.dart';

void registerChatModule(GetIt sl) {
  // ── Core Socket ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<SocketService>(() => SocketService());

  // ── Notifications ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatNotificationService>(
      () => ChatNotificationService(FirebaseMessaging.instance));

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(sl<Dio>()));

  sl.registerLazySingleton<ChatSocketDataSource>(
      () => ChatSocketDataSourceImpl(sl<SocketService>()));

  sl.registerLazySingleton<ChatLocalDataSource>(
      () => ChatLocalDataSourceImpl());

  // ── Repository ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      socketDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkConversationReadUseCase(sl()));
  sl.registerLazySingleton(() => GetOrCreateConversationUseCase(sl()));
  sl.registerLazySingleton(() => WatchMessagesUseCase(sl()));
  sl.registerLazySingleton(() => WatchTypingUseCase(sl()));
  sl.registerLazySingleton(() => WatchPresenceUseCase(sl()));
  sl.registerLazySingleton(() => SendTypingStartUseCase(sl()));
  sl.registerLazySingleton(() => SendTypingStopUseCase(sl()));
  sl.registerLazySingleton(() => UploadMediaUseCase(sl()));
  sl.registerLazySingleton(() => SendMediaMessageUseCase(sl()));

  // ── BLoCs (factory — one per route) ──────────────────────────────────────
  sl.registerFactory(() => ConversationsBloc(
        getConversations: sl(),
        markRead: sl(),
      ));

  sl.registerFactory(() => ChatBloc(
        getMessages: sl(),
        sendMessage: sl(),
        sendMediaMessage: sl(),
        uploadMedia: sl(),
        watchMessages: sl(),
        watchTyping: sl(),
        watchPresence: sl(),
        sendTypingStart: sl(),
        sendTypingStop: sl(),
        markRead: sl(),
      ));
}
