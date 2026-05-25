import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';

abstract interface class NotificationRepository {
  // ── Read ────────────────────────────────────────────────────────────────────

  Future<Either<Failure, PaginatedResponse<NotificationEntity>>> getNotifications({
    int page = 1,
    int perPage = 20,
    NotificationFilter filter = NotificationFilter.all,
  });

  /// Live stream of unread count backed by the local Drift database.
  Stream<int> watchUnreadCount();

  // ── Write ───────────────────────────────────────────────────────────────────

  Future<Either<Failure, Unit>> saveNotification(NotificationEntity entity);

  Future<Either<Failure, Unit>> markAsRead(String notificationId);

  Future<Either<Failure, Unit>> markAllAsRead();

  Future<Either<Failure, Unit>> deleteNotification(String notificationId);

  // ── Preferences ─────────────────────────────────────────────────────────────

  Future<Either<Failure, NotificationPreferences>> getPreferences();

  Future<Either<Failure, Unit>> updatePreferences(
    NotificationPreferences preferences,
  );

  // ── Device token ─────────────────────────────────────────────────────────────

  Future<Either<Failure, Unit>> registerDeviceToken(String token);

  Future<Either<Failure, Unit>> unregisterDeviceToken(String token);
}
