import 'package:vibyuk/features/booking_engine/domain/entities/booking_negotiation_message_entity.dart';

class BookingNegotiationMessageModel {
  const BookingNegotiationMessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    this.senderAvatarUrl,
    required this.type,
    this.message,
    this.offeredPrice,
    this.currency,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String senderId;
  final NegotiationSenderRole senderRole;
  final String senderName;
  final String? senderAvatarUrl;
  final NegotiationMessageType type;
  final String? message;
  final double? offeredPrice;
  final String? currency;
  final bool isRead;
  final DateTime createdAt;

  factory BookingNegotiationMessageModel.fromJson(Map<String, dynamic> j) =>
      BookingNegotiationMessageModel(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String,
        senderId: j['sender_id'] as String,
        senderRole: NegotiationSenderRole.values.firstWhere(
            (r) => r.name == j['sender_role'],
            orElse: () => NegotiationSenderRole.business),
        senderName: j['sender_name'] as String,
        senderAvatarUrl: j['sender_avatar_url'] as String?,
        type: NegotiationMessageType.values.firstWhere(
            (t) => t.name == j['type'],
            orElse: () => NegotiationMessageType.message),
        message: j['message'] as String?,
        offeredPrice: j['offered_price'] != null
            ? (j['offered_price'] as num).toDouble()
            : null,
        currency: j['currency'] as String?,
        isRead: j['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  BookingNegotiationMessageEntity toEntity() =>
      BookingNegotiationMessageEntity(
        id: id,
        bookingId: bookingId,
        senderId: senderId,
        senderRole: senderRole,
        senderName: senderName,
        senderAvatarUrl: senderAvatarUrl,
        type: type,
        message: message,
        offeredPrice: offeredPrice,
        currency: currency,
        isRead: isRead,
        createdAt: createdAt,
      );
}
