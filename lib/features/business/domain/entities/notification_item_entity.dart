import 'package:equatable/equatable.dart';

enum NotificationType { booking, campaign, payment, team, system }

extension NotificationTypeX on NotificationType {
  String get label => switch (this) {
        NotificationType.booking => 'Booking',
        NotificationType.campaign => 'Campaign',
        NotificationType.payment => 'Payment',
        NotificationType.team => 'Team',
        NotificationType.system => 'System',
      };
}

class NotificationItemEntity extends Equatable {
  const NotificationItemEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationItemEntity markRead() => NotificationItemEntity(
        id: id,
        type: type,
        title: title,
        body: body,
        isRead: true,
        data: data,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, type, title, body, isRead, data, createdAt];
}
