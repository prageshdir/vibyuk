part of 'notification_preferences_bloc.dart';

sealed class NotificationPreferencesState {
  const NotificationPreferencesState();
}

final class NotificationPreferencesInitial extends NotificationPreferencesState {
  const NotificationPreferencesInitial();
}

final class NotificationPreferencesLoading extends NotificationPreferencesState {
  const NotificationPreferencesLoading();
}

final class NotificationPreferencesLoaded extends NotificationPreferencesState {
  final NotificationPreferences preferences;
  const NotificationPreferencesLoaded(this.preferences);
}

final class NotificationPreferencesSaving extends NotificationPreferencesState {
  final NotificationPreferences preferences;
  const NotificationPreferencesSaving(this.preferences);
}

final class NotificationPreferencesSaved extends NotificationPreferencesState {
  final NotificationPreferences preferences;
  const NotificationPreferencesSaved(this.preferences);
}

final class NotificationPreferencesError extends NotificationPreferencesState {
  final Failure failure;
  const NotificationPreferencesError(this.failure);
}
