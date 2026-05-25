import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/notifications/data/models/notification_dto.dart';
import 'package:vibyuk/features/notifications/data/models/notification_preferences_dto.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';

abstract interface class NotificationRemoteDataSource {
  Future<PaginatedResponse<NotificationEntity>> getNotifications({
    int page,
    int perPage,
    NotificationFilter filter,
  });

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  Future<NotificationPreferences> getPreferences();

  Future<void> updatePreferences(NotificationPreferences preferences);

  Future<void> registerDeviceToken(String token);

  Future<void> unregisterDeviceToken(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResponse<NotificationEntity>> getNotifications({
    int page = 1,
    int perPage = 20,
    NotificationFilter filter = NotificationFilter.all,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (filter != NotificationFilter.all) 'filter': filter.name,
      },
    );

    final payload = response.data ?? {};
    final items = (payload['data'] as List<dynamic>? ?? [])
        .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    final meta = payload['meta'] as Map<String, dynamic>? ?? {};

    AppLogger.debug('Fetched ${items.length} notifications (page $page)');

    return PaginatedResponse.fromApiResponse<NotificationEntity>(
      items: items,
      meta: meta,
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _dio.patch<void>(ApiEndpoints.markNotificationRead(notificationId));
    AppLogger.debug('Marked notification read: $notificationId');
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.patch<void>(ApiEndpoints.markAllNotificationsRead);
    AppLogger.debug('Marked all notifications as read');
  }

  @override
  Future<NotificationPreferences> getPreferences() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.notificationPreferences,
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    return NotificationPreferencesDto.fromJson(data).toEntity();
  }

  @override
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    final dto = NotificationPreferencesDto.fromEntity(preferences);
    await _dio.put<void>(
      ApiEndpoints.notificationPreferences,
      data: dto.toJson(),
    );
    AppLogger.debug('Notification preferences updated');
  }

  @override
  Future<void> registerDeviceToken(String token) async {
    await _dio.post<void>(
      ApiEndpoints.registerDeviceToken,
      data: {'token': token, 'platform': _platformName()},
    );
    AppLogger.debug('Device token registered');
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    await _dio.delete<void>(ApiEndpoints.unregisterDeviceToken(token));
    AppLogger.debug('Device token unregistered');
  }

  String _platformName() {
    // Resolved at runtime — avoids dart:io in web builds
    try {
      // ignore: do_not_use_environment
      return const String.fromEnvironment('PLATFORM', defaultValue: 'unknown');
    } catch (_) {
      return 'unknown';
    }
  }
}
