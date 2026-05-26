import 'package:equatable/equatable.dart';

enum NegotiationMessageType { offer, counterOffer, acceptance, rejection, message }

enum NegotiationSenderRole { creator, business }

class BookingNegotiationMessageEntity extends Equatable {
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

  const BookingNegotiationMessageEntity({
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

  bool get isOffer =>
      type == NegotiationMessageType.offer ||
      type == NegotiationMessageType.counterOffer;
  bool get isSystem =>
      type == NegotiationMessageType.acceptance ||
      type == NegotiationMessageType.rejection;

  @override
  List<Object?> get props => [
        id, bookingId, senderId, senderRole, senderName, senderAvatarUrl,
        type, message, offeredPrice, currency, isRead, createdAt,
      ];
}
