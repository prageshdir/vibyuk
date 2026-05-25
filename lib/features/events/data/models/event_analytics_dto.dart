import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/events/domain/entities/event_analytics_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

part 'event_analytics_dto.freezed.dart';
part 'event_analytics_dto.g.dart';

@freezed
class DailySalesDto with _$DailySalesDto {
  const DailySalesDto._();

  const factory DailySalesDto({
    required DateTime date,
    @Default(0) int tickets,
    @Default(0.0) double revenue,
  }) = _DailySalesDto;

  factory DailySalesDto.fromJson(Map<String, dynamic> json) =>
      _$DailySalesDtoFromJson(json);

  DailySales toEntity() =>
      DailySales(date: date, tickets: tickets, revenue: revenue);
}

@freezed
class TicketTypeSalesDto with _$TicketTypeSalesDto {
  const TicketTypeSalesDto._();

  const factory TicketTypeSalesDto({
    @JsonKey(name: 'ticket_type_id') required String ticketTypeId,
    @Default('') String name,
    @Default('standard') String tier,
    @Default(0) int quantity,
    @Default(0.0) double revenue,
  }) = _TicketTypeSalesDto;

  factory TicketTypeSalesDto.fromJson(Map<String, dynamic> json) =>
      _$TicketTypeSalesDtoFromJson(json);

  TicketTypeSales toEntity() => TicketTypeSales(
    ticketTypeId: ticketTypeId, name: name,
    tier: TicketTier.values.firstWhere((t) => t.name == tier,
        orElse: () => TicketTier.standard),
    quantity: quantity, revenue: revenue,
  );
}

@freezed
class EventAnalyticsDto with _$EventAnalyticsDto {
  const EventAnalyticsDto._();

  const factory EventAnalyticsDto({
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'total_capacity') @Default(0) int totalCapacity,
    @JsonKey(name: 'sold_tickets') @Default(0) int soldTickets,
    @JsonKey(name: 'checked_in') @Default(0) int checkedIn,
    @JsonKey(name: 'total_revenue') @Default(0.0) double totalRevenue,
    @JsonKey(name: 'refunded_amount') @Default(0.0) double refundedAmount,
    @JsonKey(name: 'service_fees') @Default(0.0) double serviceFees,
    @JsonKey(name: 'sales_by_type') @Default([]) List<TicketTypeSalesDto> salesByType,
    @JsonKey(name: 'daily_sales') @Default([]) List<DailySalesDto> dailySales,
    @JsonKey(name: 'pending_refunds') @Default(0) int pendingRefunds,
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
  }) = _EventAnalyticsDto;

  factory EventAnalyticsDto.fromJson(Map<String, dynamic> json) =>
      _$EventAnalyticsDtoFromJson(json);

  EventAnalyticsEntity toEntity() => EventAnalyticsEntity(
    eventId: eventId, totalCapacity: totalCapacity, soldTickets: soldTickets,
    checkedIn: checkedIn, totalRevenue: totalRevenue,
    refundedAmount: refundedAmount, serviceFees: serviceFees,
    salesByType: salesByType.map((s) => s.toEntity()).toList(),
    dailySales: dailySales.map((d) => d.toEntity()).toList(),
    pendingRefunds: pendingRefunds, lastUpdated: lastUpdated,
  );
}
