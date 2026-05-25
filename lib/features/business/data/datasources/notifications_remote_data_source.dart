import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';

abstract interface class NotificationsRemoteDataSource {
  Future<Map<String, dynamic>> getNotifications(
      {required int page, required int pageSize, required bool unreadOnly});
  Future<void> markNotificationRead(String notificationId);
  Future<void> markAllNotificationsRead();
  Future<int> getUnreadCount();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  @override
  Future<Map<String, dynamic>> getNotifications({
    required int page,
    required int pageSize,
    required bool unreadOnly,
  }) async {
    final response = await _dio.get(ApiEndpoints.notifications,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (unreadOnly) 'unread_only': true,
        });
    return _data(response);
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    await _dio.post(ApiEndpoints.markNotificationRead(notificationId));
  }

  @override
  Future<void> markAllNotificationsRead() async {
    await _dio.post(ApiEndpoints.markAllNotificationsRead);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get('${ApiEndpoints.notifications}/unread-count');
    final body = response.data as Map<String, dynamic>;
    return body['count'] as int? ?? 0;
  }
}
