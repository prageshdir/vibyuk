import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';

class NotificationGroup extends Equatable {
  final String label;
  final DateTime date;
  final List<NotificationEntity> notifications;

  const NotificationGroup({
    required this.label,
    required this.date,
    required this.notifications,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;
  bool get isEmpty => notifications.isEmpty;

  NotificationGroup copyWith({
    String? label,
    DateTime? date,
    List<NotificationEntity>? notifications,
  }) {
    return NotificationGroup(
      label: label ?? this.label,
      date: date ?? this.date,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [label, date, notifications];
}
