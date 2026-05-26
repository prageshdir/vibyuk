import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool bookingAlerts;
  final bool chatAlerts;
  final bool paymentAlerts;
  final bool campaignAlerts;
  final bool reviewAlerts;
  final bool eventAlerts;
  final bool generalAlerts;
  final bool doNotDisturb;
  final String? dndStartTime;
  final String? dndEndTime;
  final String notificationSound;
  final bool vibrationEnabled;

  const NotificationPreferences({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.bookingAlerts = true,
    this.chatAlerts = true,
    this.paymentAlerts = true,
    this.campaignAlerts = true,
    this.reviewAlerts = true,
    this.eventAlerts = true,
    this.generalAlerts = true,
    this.doNotDisturb = false,
    this.dndStartTime,
    this.dndEndTime,
    this.notificationSound = 'default',
    this.vibrationEnabled = true,
  });

  factory NotificationPreferences.defaults() => const NotificationPreferences();

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? bookingAlerts,
    bool? chatAlerts,
    bool? paymentAlerts,
    bool? campaignAlerts,
    bool? reviewAlerts,
    bool? eventAlerts,
    bool? generalAlerts,
    bool? doNotDisturb,
    String? dndStartTime,
    String? dndEndTime,
    String? notificationSound,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      bookingAlerts: bookingAlerts ?? this.bookingAlerts,
      chatAlerts: chatAlerts ?? this.chatAlerts,
      paymentAlerts: paymentAlerts ?? this.paymentAlerts,
      campaignAlerts: campaignAlerts ?? this.campaignAlerts,
      reviewAlerts: reviewAlerts ?? this.reviewAlerts,
      eventAlerts: eventAlerts ?? this.eventAlerts,
      generalAlerts: generalAlerts ?? this.generalAlerts,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      dndStartTime: dndStartTime ?? this.dndStartTime,
      dndEndTime: dndEndTime ?? this.dndEndTime,
      notificationSound: notificationSound ?? this.notificationSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        pushEnabled,
        emailEnabled,
        bookingAlerts,
        chatAlerts,
        paymentAlerts,
        campaignAlerts,
        reviewAlerts,
        eventAlerts,
        generalAlerts,
        doNotDisturb,
        dndStartTime,
        dndEndTime,
        notificationSound,
        vibrationEnabled,
      ];
}
