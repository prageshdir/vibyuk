import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

part 'ticket_type_dto.freezed.dart';
part 'ticket_type_dto.g.dart';

@freezed
class TicketTypeDto with _$TicketTypeDto {
  const TicketTypeDto._();

  const factory TicketTypeDto({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    required String name,
    String? description,
    @Default('standard') String tier,
    @Default(0.0) double price,
    @Default('USD') String currency,
    @JsonKey(name: 'total_quantity') @Default(0) int totalQuantity,
    @JsonKey(name: 'sold_quantity') @Default(0) int soldQuantity,
    @JsonKey(name: 'sale_start_date') DateTime? saleStartDate,
    @JsonKey(name: 'sale_end_date') DateTime? saleEndDate,
    @JsonKey(name: 'max_per_order') @Default(10) int maxPerOrder,
    @Default([]) List<String> perks,
    @JsonKey(name: 'is_visible') @Default(true) bool isVisible,
  }) = _TicketTypeDto;

  factory TicketTypeDto.fromJson(Map<String, dynamic> json) =>
      _$TicketTypeDtoFromJson(json);

  TicketTypeEntity toEntity() => TicketTypeEntity(
    id: id, eventId: eventId, name: name, description: description,
    tier: TicketTier.values.firstWhere((t) => t.name == tier,
        orElse: () => TicketTier.standard),
    price: price, currency: currency,
    totalQuantity: totalQuantity, soldQuantity: soldQuantity,
    saleStartDate: saleStartDate, saleEndDate: saleEndDate,
    maxPerOrder: maxPerOrder, perks: perks, isVisible: isVisible,
  );
}
