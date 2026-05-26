import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/profile/domain/entities/notification_settings_entity.dart';

part 'notification_settings_model.freezed.dart';
part 'notification_settings_model.g.dart';

@freezed
class NotificationSettingsModel with _$NotificationSettingsModel {
  const NotificationSettingsModel._();

  const factory NotificationSettingsModel({
    @JsonKey(name: 'push_enabled') @Default(true) bool pushEnabled,
    @JsonKey(name: 'email_enabled') @Default(true) bool emailEnabled,
    @JsonKey(name: 'booking_notifications') @Default(true) bool bookingNotifications,
    @JsonKey(name: 'message_notifications') @Default(true) bool messageNotifications,
    @JsonKey(name: 'review_notifications') @Default(true) bool reviewNotifications,
    @JsonKey(name: 'marketing_notifications') @Default(false) bool marketingNotifications,
    @JsonKey(name: 'security_notifications') @Default(true) bool securityNotifications,
  }) = _NotificationSettingsModel;

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);

  factory NotificationSettingsModel.fromEntity(NotificationSettingsEntity entity) =>
      NotificationSettingsModel(
        pushEnabled: entity.pushEnabled,
        emailEnabled: entity.emailEnabled,
        bookingNotifications: entity.bookingNotifications,
        messageNotifications: entity.messageNotifications,
        reviewNotifications: entity.reviewNotifications,
        marketingNotifications: entity.marketingNotifications,
        securityNotifications: entity.securityNotifications,
      );

  NotificationSettingsEntity toEntity() => NotificationSettingsEntity(
        pushEnabled: pushEnabled,
        emailEnabled: emailEnabled,
        bookingNotifications: bookingNotifications,
        messageNotifications: messageNotifications,
        reviewNotifications: reviewNotifications,
        marketingNotifications: marketingNotifications,
        securityNotifications: securityNotifications,
      );
}
