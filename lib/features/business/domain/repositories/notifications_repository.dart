import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/notification_item_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';

abstract interface class NotificationsRepository {
  Future<Either<Failure, PaginatedResult<NotificationItemEntity>>> getNotifications({
    required int page,
    int pageSize = 20,
    bool unreadOnly = false,
  });

  Future<Either<Failure, Unit>> markNotificationRead(String notificationId);

  Future<Either<Failure, Unit>> markAllNotificationsRead();

  Future<Either<Failure, int>> getUnreadCount();
}
