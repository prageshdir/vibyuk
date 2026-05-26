import 'package:vibyuk/features/business/domain/entities/notification_item_entity.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'system',
        title: json['title'] as String,
        body: json['body'] as String,
        isRead: json['is_read'] as bool? ?? false,
        data: json['data'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  NotificationItemEntity toEntity() => NotificationItemEntity(
        id: id,
        type: NotificationType.values.firstWhere(
          (t) => t.name == type,
          orElse: () => NotificationType.system,
        ),
        title: title,
        body: body,
        isRead: isRead,
        data: data,
        createdAt: createdAt,
      );
}
