import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';

part 'notification_preferences_dto.freezed.dart';
part 'notification_preferences_dto.g.dart';

@freezed
class NotificationPreferencesDto with _$NotificationPreferencesDto {
  const NotificationPreferencesDto._();

  const factory NotificationPreferencesDto({
    @JsonKey(name: 'push_enabled') @Default(true) bool pushEnabled,
    @JsonKey(name: 'email_enabled') @Default(true) bool emailEnabled,
    @JsonKey(name: 'booking_alerts') @Default(true) bool bookingAlerts,
    @JsonKey(name: 'chat_alerts') @Default(true) bool chatAlerts,
    @JsonKey(name: 'payment_alerts') @Default(true) bool paymentAlerts,
    @JsonKey(name: 'campaign_alerts') @Default(true) bool campaignAlerts,
    @JsonKey(name: 'review_alerts') @Default(true) bool reviewAlerts,
    @JsonKey(name: 'event_alerts') @Default(true) bool eventAlerts,
    @JsonKey(name: 'general_alerts') @Default(true) bool generalAlerts,
    @JsonKey(name: 'do_not_disturb') @Default(false) bool doNotDisturb,
    @JsonKey(name: 'dnd_start') String? dndStartTime,
    @JsonKey(name: 'dnd_end') String? dndEndTime,
    @JsonKey(name: 'sound') @Default('default') String notificationSound,
    @JsonKey(name: 'vibration') @Default(true) bool vibrationEnabled,
  }) = _NotificationPreferencesDto;

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesDtoFromJson(json);

  NotificationPreferences toEntity() => NotificationPreferences(
        pushEnabled: pushEnabled,
        emailEnabled: emailEnabled,
        bookingAlerts: bookingAlerts,
        chatAlerts: chatAlerts,
        paymentAlerts: paymentAlerts,
        campaignAlerts: campaignAlerts,
        reviewAlerts: reviewAlerts,
        eventAlerts: eventAlerts,
        generalAlerts: generalAlerts,
        doNotDisturb: doNotDisturb,
        dndStartTime: dndStartTime,
        dndEndTime: dndEndTime,
        notificationSound: notificationSound,
        vibrationEnabled: vibrationEnabled,
      );

  static NotificationPreferencesDto fromEntity(
    NotificationPreferences entity,
  ) =>
      NotificationPreferencesDto(
        pushEnabled: entity.pushEnabled,
        emailEnabled: entity.emailEnabled,
        bookingAlerts: entity.bookingAlerts,
        chatAlerts: entity.chatAlerts,
        paymentAlerts: entity.paymentAlerts,
        campaignAlerts: entity.campaignAlerts,
        reviewAlerts: entity.reviewAlerts,
        eventAlerts: entity.eventAlerts,
        generalAlerts: entity.generalAlerts,
        doNotDisturb: entity.doNotDisturb,
        dndStartTime: entity.dndStartTime,
        dndEndTime: entity.dndEndTime,
        notificationSound: entity.notificationSound,
        vibrationEnabled: entity.vibrationEnabled,
      );
}
