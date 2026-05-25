import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/notifications/models/push_notification_model.dart';

export 'package:vibyuk/core/notifications/models/push_notification_model.dart'
    show NotificationType;

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? deepLink;
  final DateTime receivedAt;
  final bool isRead;
  final String? groupKey;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.general,
    this.data,
    this.imageUrl,
    this.deepLink,
    required this.receivedAt,
    this.isRead = false,
    this.groupKey,
  });

  factory NotificationEntity.fromPush(PushNotificationModel push) =>
      NotificationEntity(
        id: push.id,
        title: push.title,
        body: push.body,
        type: push.type,
        data: push.data,
        imageUrl: push.imageUrl,
        deepLink: push.deepLink,
        receivedAt: push.receivedAt ?? DateTime.now(),
        isRead: push.isRead,
      );

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? deepLink,
    DateTime? receivedAt,
    bool? isRead,
    String? groupKey,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      deepLink: deepLink ?? this.deepLink,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
      groupKey: groupKey ?? this.groupKey,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, body, type, data, imageUrl, deepLink, receivedAt, isRead, groupKey];
}
