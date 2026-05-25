import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:vibyuk/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';

class NotificationRepositoryImpl extends BaseRepository
    implements NotificationRepository {
  const NotificationRepositoryImpl({
    required NotificationLocalDataSource local,
    required NotificationRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final NotificationLocalDataSource _local;
  final NotificationRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedResponse<NotificationEntity>>>
      getNotifications({
    int page = 1,
    int perPage = 20,
    NotificationFilter filter = NotificationFilter.all,
  }) async {
    // Local-first: serve from cache, attempt remote sync in background
    return safeCall(() async {
      final localItems = await _local.getNotifications(
        page: page,
        perPage: perPage,
        filter: filter,
      );
      final total = await _local.getTotalCount(filter: filter);

      if (page == 1) {
        // Fire-and-forget remote sync for first page
        _syncFromRemote(page: page, perPage: perPage, filter: filter);
      }

      return PaginatedResponse<NotificationEntity>(
        items: localItems,
        currentPage: page,
        totalPages: (total / perPage).ceil().clamp(1, double.infinity).toInt(),
        totalItems: total,
        perPage: perPage,
      );
    }, context: 'NotificationRepository.getNotifications');
  }

  Future<void> _syncFromRemote({
    required int page,
    required int perPage,
    required NotificationFilter filter,
  }) async {
    try {
      final remote = await _remote.getNotifications(
        page: page,
        perPage: perPage,
        filter: filter,
      );
      for (final entity in remote.items) {
        await _local.saveNotification(entity);
      }
    } catch (_) {
      // Silent fail — local data is the source of truth for the UI
    }
  }

  @override
  Stream<int> watchUnreadCount() => _local.watchUnreadCount();

  @override
  Future<Either<Failure, Unit>> saveNotification(
    NotificationEntity entity,
  ) =>
      safeCall(
        () async {
          await _local.saveNotification(entity);
          return unit;
        },
        context: 'NotificationRepository.saveNotification',
      );

  @override
  Future<Either<Failure, Unit>> markAsRead(String notificationId) =>
      safeCall(
        () async {
          await _local.markAsRead(notificationId);
          // Best-effort remote sync
          _remote.markAsRead(notificationId).ignore();
          return unit;
        },
        context: 'NotificationRepository.markAsRead',
      );

  @override
  Future<Either<Failure, Unit>> markAllAsRead() => safeCall(
        () async {
          await _local.markAllAsRead();
          _remote.markAllAsRead().ignore();
          return unit;
        },
        context: 'NotificationRepository.markAllAsRead',
      );

  @override
  Future<Either<Failure, Unit>> deleteNotification(String notificationId) =>
      safeCall(
        () async {
          await _local.deleteNotification(notificationId);
          return unit;
        },
        context: 'NotificationRepository.deleteNotification',
      );

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() =>
      safeCall(
        () async {
          final cached = await _local.getCachedPreferences();
          if (cached != null) return cached;

          final remote = await _remote.getPreferences();
          await _local.cachePreferences(remote);
          return remote;
        },
        context: 'NotificationRepository.getPreferences',
      );

  @override
  Future<Either<Failure, Unit>> updatePreferences(
    NotificationPreferences preferences,
  ) =>
      safeCall(
        () async {
          await Future.wait([
            _local.cachePreferences(preferences),
            _remote.updatePreferences(preferences),
          ]);
          return unit;
        },
        context: 'NotificationRepository.updatePreferences',
      );

  @override
  Future<Either<Failure, Unit>> registerDeviceToken(String token) => safeCall(
        () async {
          await _remote.registerDeviceToken(token);
          return unit;
        },
        context: 'NotificationRepository.registerDeviceToken',
      );

  @override
  Future<Either<Failure, Unit>> unregisterDeviceToken(String token) =>
      safeCall(
        () async {
          await _remote.unregisterDeviceToken(token);
          return unit;
        },
        context: 'NotificationRepository.unregisterDeviceToken',
      );
}
