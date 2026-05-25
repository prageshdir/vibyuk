import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

enum TicketStatus { active, used, cancelled, refunded, expired }

class TicketEntity extends Equatable {
  final String id;
  final String eventId;
  final String eventTitle;
  final String? eventCoverUrl;
  final DateTime eventStartDate;
  final String venueName;
  final String ticketTypeId;
  final String ticketTypeName;
  final TicketTier ticketTier;
  final String userId;
  final String ownerName;
  final String ownerEmail;
  final String qrData;
  final TicketStatus status;
  final double paidAmount;
  final String currency;
  final DateTime purchasedAt;
  final DateTime? checkedInAt;
  final String? refundId;
  final String orderRef;

  const TicketEntity({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    this.eventCoverUrl,
    required this.eventStartDate,
    required this.venueName,
    required this.ticketTypeId,
    required this.ticketTypeName,
    this.ticketTier = TicketTier.standard,
    required this.userId,
    required this.ownerName,
    required this.ownerEmail,
    required this.qrData,
    this.status = TicketStatus.active,
    required this.paidAmount,
    this.currency = 'USD',
    required this.purchasedAt,
    this.checkedInAt,
    this.refundId,
    required this.orderRef,
  });

  bool get isValid => status == TicketStatus.active;
  bool get isUsed => status == TicketStatus.used;
  bool get isCancelled =>
      status == TicketStatus.cancelled || status == TicketStatus.refunded;
  bool get canRefund => status == TicketStatus.active;
  bool get isEventUpcoming => DateTime.now().isBefore(eventStartDate);

  TicketEntity copyWith({
    String? id, String? eventId, String? eventTitle, String? eventCoverUrl,
    DateTime? eventStartDate, String? venueName, String? ticketTypeId,
    String? ticketTypeName, TicketTier? ticketTier, String? userId,
    String? ownerName, String? ownerEmail, String? qrData,
    TicketStatus? status, double? paidAmount, String? currency,
    DateTime? purchasedAt, DateTime? checkedInAt, String? refundId, String? orderRef,
  }) => TicketEntity(
    id: id ?? this.id, eventId: eventId ?? this.eventId,
    eventTitle: eventTitle ?? this.eventTitle,
    eventCoverUrl: eventCoverUrl ?? this.eventCoverUrl,
    eventStartDate: eventStartDate ?? this.eventStartDate,
    venueName: venueName ?? this.venueName,
    ticketTypeId: ticketTypeId ?? this.ticketTypeId,
    ticketTypeName: ticketTypeName ?? this.ticketTypeName,
    ticketTier: ticketTier ?? this.ticketTier,
    userId: userId ?? this.userId, ownerName: ownerName ?? this.ownerName,
    ownerEmail: ownerEmail ?? this.ownerEmail, qrData: qrData ?? this.qrData,
    status: status ?? this.status, paidAmount: paidAmount ?? this.paidAmount,
    currency: currency ?? this.currency, purchasedAt: purchasedAt ?? this.purchasedAt,
    checkedInAt: checkedInAt ?? this.checkedInAt, refundId: refundId ?? this.refundId,
    orderRef: orderRef ?? this.orderRef,
  );

  @override
  List<Object?> get props => [id, eventId, eventTitle, eventCoverUrl, eventStartDate,
    venueName, ticketTypeId, ticketTypeName, ticketTier, userId, ownerName,
    ownerEmail, qrData, status, paidAmount, currency, purchasedAt,
    checkedInAt, refundId, orderRef];
}
