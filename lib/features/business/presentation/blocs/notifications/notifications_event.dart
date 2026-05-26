part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class LoadNotificationsEvent extends NotificationsEvent {
  const LoadNotificationsEvent({this.unreadOnly = false});
  final bool unreadOnly;
  @override
  List<Object?> get props => [unreadOnly];
}

class LoadMoreNotificationsEvent extends NotificationsEvent {
  const LoadMoreNotificationsEvent();
  @override
  List<Object?> get props => [];
}

class MarkNotificationReadEvent extends NotificationsEvent {
  const MarkNotificationReadEvent({required this.notificationId});
  final String notificationId;
  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsReadEvent extends NotificationsEvent {
  const MarkAllNotificationsReadEvent();
  @override
  List<Object?> get props => [];
}
