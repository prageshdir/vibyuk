import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

part 'ticket_dto.freezed.dart';
part 'ticket_dto.g.dart';

@freezed
class TicketDto with _$TicketDto {
  const TicketDto._();

  const factory TicketDto({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'event_title') @Default('') String eventTitle,
    @JsonKey(name: 'event_cover_url') String? eventCoverUrl,
    @JsonKey(name: 'event_start_date') required DateTime eventStartDate,
    @JsonKey(name: 'venue_name') @Default('') String venueName,
    @JsonKey(name: 'ticket_type_id') required String ticketTypeId,
    @JsonKey(name: 'ticket_type_name') @Default('') String ticketTypeName,
    @JsonKey(name: 'ticket_tier') @Default('standard') String ticketTier,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'owner_name') @Default('') String ownerName,
    @JsonKey(name: 'owner_email') @Default('') String ownerEmail,
    @JsonKey(name: 'qr_data') @Default('') String qrData,
    @Default('active') String status,
    @JsonKey(name: 'paid_amount') @Default(0.0) double paidAmount,
    @Default('INR') String currency,
    @JsonKey(name: 'purchased_at') required DateTime purchasedAt,
    @JsonKey(name: 'checked_in_at') DateTime? checkedInAt,
    @JsonKey(name: 'refund_id') String? refundId,
    @JsonKey(name: 'order_ref') @Default('') String orderRef,
  }) = _TicketDto;

  factory TicketDto.fromJson(Map<String, dynamic> json) =>
      _$TicketDtoFromJson(json);

  TicketEntity toEntity() => TicketEntity(
    id: id, eventId: eventId, eventTitle: eventTitle,
    eventCoverUrl: eventCoverUrl, eventStartDate: eventStartDate,
    venueName: venueName, ticketTypeId: ticketTypeId,
    ticketTypeName: ticketTypeName,
    ticketTier: TicketTier.values.firstWhere((t) => t.name == ticketTier,
        orElse: () => TicketTier.standard),
    userId: userId, ownerName: ownerName, ownerEmail: ownerEmail,
    qrData: qrData,
    status: TicketStatus.values.firstWhere((s) => s.name == status,
        orElse: () => TicketStatus.active),
    paidAmount: paidAmount, currency: currency, purchasedAt: purchasedAt,
    checkedInAt: checkedInAt, refundId: refundId, orderRef: orderRef,
  );
}
