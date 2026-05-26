import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_model.freezed.dart';
part 'push_notification_model.g.dart';

enum NotificationType {
  // Booking
  bookingRequest,
  bookingConfirmed,
  bookingCancelled,
  bookingReminder,
  // Chat
  newMessage,
  // Payment
  paymentReceived,
  paymentFailed,
  paymentRefunded,
  // Campaign
  campaignStarted,
  campaignEnded,
  campaignUpdate,
  // Review
  newReview,
  // Event
  eventReminder,
  eventUpdate,
  eventCancelled,
  // Social
  creatorFollowed,
  // System
  systemAlert,
  general,
}

extension NotificationTypeX on NotificationType {
  bool get isBooking => [
        NotificationType.bookingRequest,
        NotificationType.bookingConfirmed,
        NotificationType.bookingCancelled,
        NotificationType.bookingReminder,
      ].contains(this);

  bool get isPayment => [
        NotificationType.paymentReceived,
        NotificationType.paymentFailed,
        NotificationType.paymentRefunded,
      ].contains(this);

  bool get isCampaign => [
        NotificationType.campaignStarted,
        NotificationType.campaignEnded,
        NotificationType.campaignUpdate,
      ].contains(this);

  bool get isEvent => [
        NotificationType.eventReminder,
        NotificationType.eventUpdate,
        NotificationType.eventCancelled,
      ].contains(this);

  bool get isChat => this == NotificationType.newMessage;
}

@freezed
class PushNotificationModel with _$PushNotificationModel {
  const PushNotificationModel._();

  const factory PushNotificationModel({
    required String id,
    required String title,
    required String body,
    @Default(NotificationType.general) NotificationType type,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? deepLink,
    DateTime? receivedAt,
    @Default(false) bool isRead,
  }) = _PushNotificationModel;

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationModelFromJson(json);

  factory PushNotificationModel.fromFcmMessage(Map<String, dynamic> message) {
    final notification = message['notification'] as Map<String, dynamic>? ?? {};
    final data = message['data'] as Map<String, dynamic>? ?? {};

    return PushNotificationModel(
      id: data['notification_id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification['title']?.toString() ?? '',
      body: notification['body']?.toString() ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NotificationType.general,
      ),
      data: data,
      imageUrl: notification['image']?.toString(),
      deepLink: data['deep_link']?.toString(),
      receivedAt: DateTime.now(),
    );
  }
}
