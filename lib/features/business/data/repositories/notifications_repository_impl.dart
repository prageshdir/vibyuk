import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/data/datasources/notifications_remote_data_source.dart';
import 'package:vibyuk/features/business/data/models/notification_model.dart';
import 'package:vibyuk/features/business/domain/entities/notification_item_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl extends BaseRepository
    implements NotificationsRepository {
  NotificationsRepositoryImpl(
      {required NotificationsRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final NotificationsRemoteDataSource _remote;

  PaginatedResult<NotificationItemEntity> _parsePaginated(
      Map<String, dynamic> data) {
    final items = (data['items'] as List? ?? data['data'] as List? ?? [])
        .map((e) =>
            NotificationModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    return PaginatedResult<NotificationItemEntity>(
      items: items,
      currentPage: data['current_page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
      totalItems: data['total_items'] as int? ?? items.length,
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<NotificationItemEntity>>>
      getNotifications({
    required int page,
    int pageSize = 20,
    bool unreadOnly = false,
  }) =>
          safeCall(() async {
            final data = await _remote.getNotifications(
                page: page, pageSize: pageSize, unreadOnly: unreadOnly);
            return _parsePaginated(data);
          });

  @override
  Future<Either<Failure, Unit>> markNotificationRead(String notificationId) =>
      safeCall(() async {
        await _remote.markNotificationRead(notificationId);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> markAllNotificationsRead() =>
      safeCall(() async {
        await _remote.markAllNotificationsRead();
        return unit;
      });

  @override
  Future<Either<Failure, int>> getUnreadCount() =>
      safeCall(() => _remote.getUnreadCount());
}
