import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';
import 'package:vibyuk/features/notifications/domain/usecases/get_notification_preferences_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/update_notification_preferences_usecase.dart';

part 'notification_preferences_event.dart';
part 'notification_preferences_state.dart';

class NotificationPreferencesBloc extends BaseBloc<NotificationPreferencesEvent,
    NotificationPreferencesState> {
  NotificationPreferencesBloc({
    required GetNotificationPreferencesUseCase getPreferences,
    required UpdateNotificationPreferencesUseCase updatePreferences,
  })  : _getPreferences = getPreferences,
        _updatePreferences = updatePreferences,
        super(const NotificationPreferencesInitial()) {
    on<NotificationPreferencesLoadRequested>(_onLoad);
    on<NotificationPreferencesUpdateRequested>(_onUpdate);
  }

  final GetNotificationPreferencesUseCase _getPreferences;
  final UpdateNotificationPreferencesUseCase _updatePreferences;

  Future<void> _onLoad(
    NotificationPreferencesLoadRequested event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    emit(const NotificationPreferencesLoading());

    final result = await _getPreferences();
    result.fold(
      (failure) => emit(NotificationPreferencesError(failure)),
      (prefs) => emit(NotificationPreferencesLoaded(prefs)),
    );
  }

  Future<void> _onUpdate(
    NotificationPreferencesUpdateRequested event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    emit(NotificationPreferencesSaving(event.preferences));

    final result =
        await _updatePreferences(UpdatePreferencesParams(event.preferences));
    result.fold(
      (failure) => emit(NotificationPreferencesError(failure)),
      (_) => emit(NotificationPreferencesSaved(event.preferences)),
    );
  }
}
