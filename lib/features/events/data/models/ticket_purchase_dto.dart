import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/events/data/models/ticket_dto.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_purchase_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

part 'ticket_purchase_dto.freezed.dart';
part 'ticket_purchase_dto.g.dart';

@freezed
class TicketOrderLineDto with _$TicketOrderLineDto {
  const TicketOrderLineDto._();

  const factory TicketOrderLineDto({
    @JsonKey(name: 'ticket_type_id') required String ticketTypeId,
    @JsonKey(name: 'ticket_type_name') @Default('') String ticketTypeName,
    @Default('standard') String tier,
    @Default(1) int quantity,
    @JsonKey(name: 'unit_price') @Default(0.0) double unitPrice,
    @Default('USD') String currency,
  }) = _TicketOrderLineDto;

  factory TicketOrderLineDto.fromJson(Map<String, dynamic> json) =>
      _$TicketOrderLineDtoFromJson(json);

  TicketOrderLine toEntity() => TicketOrderLine(
    ticketTypeId: ticketTypeId, ticketTypeName: ticketTypeName,
    tier: TicketTier.values.firstWhere((t) => t.name == tier,
        orElse: () => TicketTier.standard),
    quantity: quantity, unitPrice: unitPrice, currency: currency,
  );
}

@freezed
class TicketPurchaseDto with _$TicketPurchaseDto {
  const TicketPurchaseDto._();

  const factory TicketPurchaseDto({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'event_title') @Default('') String eventTitle,
    @Default([]) List<TicketOrderLineDto> lines,
    @Default(0.0) double subtotal,
    @JsonKey(name: 'service_fee') @Default(0.0) double serviceFee,
    @Default(0.0) double total,
    @Default('USD') String currency,
    @Default('pending') String status,
    @JsonKey(name: 'payment_intent_id') String? paymentIntentId,
    @Default([]) List<TicketDto> tickets,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TicketPurchaseDto;

  factory TicketPurchaseDto.fromJson(Map<String, dynamic> json) =>
      _$TicketPurchaseDtoFromJson(json);

  TicketPurchaseEntity toEntity() => TicketPurchaseEntity(
    id: id, eventId: eventId, eventTitle: eventTitle,
    lines: lines.map((l) => l.toEntity()).toList(),
    subtotal: subtotal, serviceFee: serviceFee, total: total,
    currency: currency,
    status: PurchaseStatus.values.firstWhere((s) => s.name == status,
        orElse: () => PurchaseStatus.pending),
    paymentIntentId: paymentIntentId,
    tickets: tickets.map((t) => t.toEntity()).toList(),
    createdAt: createdAt,
  );
}
