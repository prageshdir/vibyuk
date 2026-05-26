import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

enum PurchaseStatus { pending, processing, completed, failed, refunded }

class TicketOrderLine extends Equatable {
  final String ticketTypeId;
  final String ticketTypeName;
  final TicketTier tier;
  final int quantity;
  final double unitPrice;
  final String currency;

  const TicketOrderLine({
    required this.ticketTypeId,
    required this.ticketTypeName,
    required this.tier,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
  });

  double get lineTotal => quantity * unitPrice;

  TicketOrderLine copyWith({
    String? ticketTypeId, String? ticketTypeName, TicketTier? tier,
    int? quantity, double? unitPrice, String? currency,
  }) => TicketOrderLine(
    ticketTypeId: ticketTypeId ?? this.ticketTypeId,
    ticketTypeName: ticketTypeName ?? this.ticketTypeName,
    tier: tier ?? this.tier,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    currency: currency ?? this.currency,
  );

  @override
  List<Object?> get props =>
      [ticketTypeId, ticketTypeName, tier, quantity, unitPrice, currency];
}

class TicketPurchaseEntity extends Equatable {
  final String id;
  final String eventId;
  final String eventTitle;
  final List<TicketOrderLine> lines;
  final double subtotal;
  final double serviceFee;
  final double total;
  final String currency;
  final PurchaseStatus status;
  final String? paymentIntentId;
  final List<TicketEntity> tickets;
  final DateTime createdAt;

  const TicketPurchaseEntity({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.lines,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
    required this.currency,
    required this.status,
    this.paymentIntentId,
    this.tickets = const [],
    required this.createdAt,
  });

  int get totalTickets => lines.fold(0, (s, l) => s + l.quantity);

  TicketPurchaseEntity copyWith({
    String? id, String? eventId, String? eventTitle,
    List<TicketOrderLine>? lines, double? subtotal, double? serviceFee,
    double? total, String? currency, PurchaseStatus? status,
    String? paymentIntentId, List<TicketEntity>? tickets, DateTime? createdAt,
  }) => TicketPurchaseEntity(
    id: id ?? this.id, eventId: eventId ?? this.eventId,
    eventTitle: eventTitle ?? this.eventTitle,
    lines: lines ?? this.lines, subtotal: subtotal ?? this.subtotal,
    serviceFee: serviceFee ?? this.serviceFee, total: total ?? this.total,
    currency: currency ?? this.currency, status: status ?? this.status,
    paymentIntentId: paymentIntentId ?? this.paymentIntentId,
    tickets: tickets ?? this.tickets, createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [id, eventId, eventTitle, lines, subtotal,
    serviceFee, total, currency, status, paymentIntentId, tickets, createdAt];
}
