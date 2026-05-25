part of 'notification_preferences_bloc.dart';

sealed class NotificationPreferencesEvent {
  const NotificationPreferencesEvent();
}

final class NotificationPreferencesLoadRequested
    extends NotificationPreferencesEvent {
  const NotificationPreferencesLoadRequested();
}

final class NotificationPreferencesUpdateRequested
    extends NotificationPreferencesEvent {
  final NotificationPreferences preferences;
  const NotificationPreferencesUpdateRequested(this.preferences);
}
