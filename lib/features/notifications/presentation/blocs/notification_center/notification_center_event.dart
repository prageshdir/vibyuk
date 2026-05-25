part of 'notification_center_bloc.dart';

sealed class NotificationCenterEvent {
  const NotificationCenterEvent();
}

final class NotificationCenterLoadRequested extends NotificationCenterEvent {
  const NotificationCenterLoadRequested();
}

final class NotificationCenterRefreshRequested extends NotificationCenterEvent {
  const NotificationCenterRefreshRequested();
}

final class NotificationCenterLoadMoreRequested
    extends NotificationCenterEvent {
  const NotificationCenterLoadMoreRequested();
}

final class NotificationCenterFilterChanged extends NotificationCenterEvent {
  final NotificationFilter filter;
  const NotificationCenterFilterChanged(this.filter);
}

final class NotificationMarkReadRequested extends NotificationCenterEvent {
  final String notificationId;
  const NotificationMarkReadRequested(this.notificationId);
}

final class NotificationMarkAllReadRequested extends NotificationCenterEvent {
  const NotificationMarkAllReadRequested();
}

final class NotificationDeleteRequested extends NotificationCenterEvent {
  final String notificationId;
  const NotificationDeleteRequested(this.notificationId);
}

final class NotificationNewIncoming extends NotificationCenterEvent {
  final NotificationEntity notification;
  const NotificationNewIncoming(this.notification);
}
