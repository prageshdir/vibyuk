import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/core/notifications/notification_handler.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:vibyuk/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:vibyuk/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:vibyuk/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/get_notification_preferences_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/mark_all_read_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/register_device_token_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/save_notification_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/update_notification_preferences_usecase.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_badge/notification_badge_cubit.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_preferences/notification_preferences_bloc.dart';

void registerNotificationModule(GetIt sl) {
  // ── Data sources ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(
      dao: sl<AppDatabase>().notificationsDao,
      cache: sl<CacheManager>(),
    ),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<Dio>()),
  );

  // ── Repository ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      local: sl<NotificationLocalDataSource>(),
      remote: sl<NotificationRemoteDataSource>(),
    ),
  );

  // ── Use cases ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkNotificationReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkAllReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteNotificationUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveNotificationUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => GetNotificationPreferencesUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateNotificationPreferencesUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => RegisterDeviceTokenUseCase(sl<NotificationRepository>()),
  );

  // ── BLoCs ────────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => NotificationCenterBloc(
      getNotifications: sl<GetNotificationsUseCase>(),
      markAsRead: sl<MarkNotificationReadUseCase>(),
      markAllRead: sl<MarkAllReadUseCase>(),
      deleteNotification: sl<DeleteNotificationUseCase>(),
      saveNotification: sl<SaveNotificationUseCase>(),
      unreadCountStream: sl<NotificationRepository>().watchUnreadCount(),
    ),
  );

  sl.registerFactory(
    () => NotificationPreferencesBloc(
      getPreferences: sl<GetNotificationPreferencesUseCase>(),
      updatePreferences: sl<UpdateNotificationPreferencesUseCase>(),
    ),
  );

  // Badge cubit is a singleton so unread count is shared app-wide
  sl.registerLazySingleton(
    () => NotificationBadgeCubit(sl<NotificationRepository>()),
  );

  // ── Wire NotificationHandler to the feature layer ─────────────────────────
  _wireNotificationHandler(sl);
}

void _wireNotificationHandler(GetIt sl) {
  final handler = sl<NotificationHandler>();

  // Persist every foreground push into the local DB so it appears in the center
  handler.registerForegroundCallback((notification) {
    final entity = NotificationEntity.fromPush(notification);
    sl<SaveNotificationUseCase>()(SaveNotificationParams(entity)).ignore();
  });
}
