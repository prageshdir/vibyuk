import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preference_model.freezed.dart';
part 'notification_preference_model.g.dart';

@freezed
class NotificationPreferenceModel with _$NotificationPreferenceModel {
  const factory NotificationPreferenceModel({
    @Default(true) bool pushEnabled,
    @Default(true) bool emailEnabled,
    @Default(true) bool bookingAlerts,
    @Default(true) bool chatAlerts,
    @Default(true) bool paymentAlerts,
    @Default(true) bool campaignAlerts,
    @Default(true) bool reviewAlerts,
    @Default(true) bool eventAlerts,
    @Default(true) bool generalAlerts,
    @Default(false) bool doNotDisturb,
    @JsonKey(name: 'dnd_start') String? dndStartTime,
    @JsonKey(name: 'dnd_end') String? dndEndTime,
    @JsonKey(name: 'sound') @Default('default') String notificationSound,
    @JsonKey(name: 'vibration') @Default(true) bool vibrationEnabled,
  }) = _NotificationPreferenceModel;

  factory NotificationPreferenceModel.defaults() =>
      const NotificationPreferenceModel();

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferenceModelFromJson(json);
}
