import 'package:equatable/equatable.dart';

class NotificationSettingsEntity extends Equatable {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool bookingNotifications;
  final bool messageNotifications;
  final bool reviewNotifications;
  final bool marketingNotifications;
  final bool securityNotifications;

  const NotificationSettingsEntity({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.bookingNotifications = true,
    this.messageNotifications = true,
    this.reviewNotifications = true,
    this.marketingNotifications = false,
    this.securityNotifications = true,
  });

  NotificationSettingsEntity copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? bookingNotifications,
    bool? messageNotifications,
    bool? reviewNotifications,
    bool? marketingNotifications,
    bool? securityNotifications,
  }) {
    return NotificationSettingsEntity(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      bookingNotifications: bookingNotifications ?? this.bookingNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      reviewNotifications: reviewNotifications ?? this.reviewNotifications,
      marketingNotifications: marketingNotifications ?? this.marketingNotifications,
      securityNotifications: securityNotifications ?? this.securityNotifications,
    );
  }

  @override
  List<Object?> get props => [
        pushEnabled,
        emailEnabled,
        bookingNotifications,
        messageNotifications,
        reviewNotifications,
        marketingNotifications,
        securityNotifications,
      ];
}
