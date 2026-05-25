import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/notifications/models/push_notification_model.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';

abstract interface class NotificationLocalDataSource {
  Future<void> saveNotification(NotificationEntity entity);

  Future<List<NotificationEntity>> getNotifications({
    required int page,
    required int perPage,
    NotificationFilter filter,
  });

  Future<int> getTotalCount({NotificationFilter filter});

  Stream<int> watchUnreadCount();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);

  Future<NotificationPreferences?> getCachedPreferences();

  Future<void> cachePreferences(NotificationPreferences preferences);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  const NotificationLocalDataSourceImpl({
    required NotificationsDao dao,
    required CacheManager cache,
  })  : _dao = dao,
        _cache = cache;

  final NotificationsDao _dao;
  final CacheManager _cache;

  static const _prefsKey = 'notification_preferences';

  @override
  Future<void> saveNotification(NotificationEntity entity) async {
    try {
      await _dao.upsert(NotificationRowCompanion.insert(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        type: entity.type.name,
        dataJson: Value(entity.data != null ? jsonEncode(entity.data) : null),
        imageUrl: Value(entity.imageUrl),
        deepLink: Value(entity.deepLink),
        receivedAt: entity.receivedAt,
        isRead: Value(entity.isRead),
        groupKey: Value(entity.groupKey),
      ));
    } catch (e, st) {
      AppLogger.error(
          'Failed to save notification locally', error: e, stackTrace: st);
      throw CacheException(message: 'Failed to persist notification: $e');
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications({
    required int page,
    required int perPage,
    NotificationFilter filter = NotificationFilter.all,
  }) async {
    try {
      final rows = await _dao.getPage(
        page: page,
        perPage: perPage,
        typeFilters: _typeFiltersFor(filter),
        unreadOnly: filter == NotificationFilter.unread ? true : null,
      );
      return rows.map(_rowToEntity).toList();
    } catch (e, st) {
      AppLogger.error('Failed to read notifications', error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read notifications: $e');
    }
  }

  @override
  Future<int> getTotalCount({
    NotificationFilter filter = NotificationFilter.all,
  }) =>
      _dao.getTotalCount(
        typeFilters: _typeFiltersFor(filter),
        unreadOnly: filter == NotificationFilter.unread ? true : null,
      );

  @override
  Stream<int> watchUnreadCount() => _dao.watchUnreadCount();

  @override
  Future<void> markAsRead(String id) => _dao.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _dao.markAllAsRead();

  @override
  Future<void> deleteNotification(String id) => _dao.softDelete(id);

  @override
  Future<NotificationPreferences?> getCachedPreferences() async {
    final cached = _cache.get<NotificationPreferences>(
      _prefsKey,
      deserializer: (raw) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return _prefsFromJson(json);
      },
    );
    return cached;
  }

  @override
  Future<void> cachePreferences(NotificationPreferences preferences) async {
    await _cache.set<NotificationPreferences>(
      _prefsKey,
      preferences,
      ttl: const Duration(days: 30),
      serializer: (p) => jsonEncode(_prefsToJson(p)),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<String>? _typeFiltersFor(NotificationFilter filter) {
    return switch (filter) {
      NotificationFilter.all || NotificationFilter.unread => null,
      NotificationFilter.bookings => [
          NotificationType.bookingRequest.name,
          NotificationType.bookingConfirmed.name,
          NotificationType.bookingCancelled.name,
          NotificationType.bookingReminder.name,
        ],
      NotificationFilter.chat => [NotificationType.newMessage.name],
      NotificationFilter.payments => [
          NotificationType.paymentReceived.name,
          NotificationType.paymentFailed.name,
          NotificationType.paymentRefunded.name,
        ],
      NotificationFilter.campaigns => [
          NotificationType.campaignStarted.name,
          NotificationType.campaignEnded.name,
          NotificationType.campaignUpdate.name,
        ],
    };
  }

  NotificationEntity _rowToEntity(NotificationRow row) {
    Map<String, dynamic>? data;
    if (row.dataJson != null) {
      try {
        data = jsonDecode(row.dataJson!) as Map<String, dynamic>;
      } catch (_) {}
    }
    return NotificationEntity(
      id: row.id,
      title: row.title,
      body: row.body,
      type: NotificationType.values.firstWhere(
        (t) => t.name == row.type,
        orElse: () => NotificationType.general,
      ),
      data: data,
      imageUrl: row.imageUrl,
      deepLink: row.deepLink,
      receivedAt: row.receivedAt,
      isRead: row.isRead,
      groupKey: row.groupKey,
    );
  }

  Map<String, dynamic> _prefsToJson(NotificationPreferences p) => {
        'push_enabled': p.pushEnabled,
        'email_enabled': p.emailEnabled,
        'booking_alerts': p.bookingAlerts,
        'chat_alerts': p.chatAlerts,
        'payment_alerts': p.paymentAlerts,
        'campaign_alerts': p.campaignAlerts,
        'review_alerts': p.reviewAlerts,
        'event_alerts': p.eventAlerts,
        'general_alerts': p.generalAlerts,
        'do_not_disturb': p.doNotDisturb,
        'dnd_start': p.dndStartTime,
        'dnd_end': p.dndEndTime,
        'sound': p.notificationSound,
        'vibration': p.vibrationEnabled,
      };

  NotificationPreferences _prefsFromJson(Map<String, dynamic> j) =>
      NotificationPreferences(
        pushEnabled: j['push_enabled'] as bool? ?? true,
        emailEnabled: j['email_enabled'] as bool? ?? true,
        bookingAlerts: j['booking_alerts'] as bool? ?? true,
        chatAlerts: j['chat_alerts'] as bool? ?? true,
        paymentAlerts: j['payment_alerts'] as bool? ?? true,
        campaignAlerts: j['campaign_alerts'] as bool? ?? true,
        reviewAlerts: j['review_alerts'] as bool? ?? true,
        eventAlerts: j['event_alerts'] as bool? ?? true,
        generalAlerts: j['general_alerts'] as bool? ?? true,
        doNotDisturb: j['do_not_disturb'] as bool? ?? false,
        dndStartTime: j['dnd_start'] as String?,
        dndEndTime: j['dnd_end'] as String?,
        notificationSound: j['sound'] as String? ?? 'default',
        vibrationEnabled: j['vibration'] as bool? ?? true,
      );
}
