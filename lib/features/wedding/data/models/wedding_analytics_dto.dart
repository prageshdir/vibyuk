import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_analytics_entity.dart';

part 'wedding_analytics_dto.freezed.dart';
part 'wedding_analytics_dto.g.dart';

@freezed
class WeddingAnalyticsDto with _$WeddingAnalyticsDto {
  const factory WeddingAnalyticsDto({
    @JsonKey(name: 'wedding_id') required String weddingId,
    @JsonKey(name: 'total_budget') required double totalBudget,
    @JsonKey(name: 'budget_used') required double budgetUsed,
    @JsonKey(name: 'vendors_booked') required int vendorsBooked,
    @JsonKey(name: 'vendors_pending') required int vendorsPending,
    @JsonKey(name: 'timeline_completion_rate')
    required double timelineCompletionRate,
    @JsonKey(name: 'days_until_wedding') required int daysUntilWedding,
    @JsonKey(name: 'guest_confirmation_rate')
    required double guestConfirmationRate,
    @JsonKey(name: 'top_expense_category') required String topExpenseCategory,
    @JsonKey(name: 'budget_by_category')
    @Default({})
    Map<String, double> budgetByCategory,
  }) = _WeddingAnalyticsDto;

  factory WeddingAnalyticsDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingAnalyticsDtoFromJson(json);

  factory WeddingAnalyticsDto.fromEntity(WeddingAnalyticsEntity e) =>
      WeddingAnalyticsDto(
        weddingId: e.weddingId,
        totalBudget: e.totalBudget,
        budgetUsed: e.budgetUsed,
        vendorsBooked: e.vendorsBooked,
        vendorsPending: e.vendorsPending,
        timelineCompletionRate: e.timelineCompletionRate,
        daysUntilWedding: e.daysUntilWedding,
        guestConfirmationRate: e.guestConfirmationRate,
        topExpenseCategory: e.topExpenseCategory,
        budgetByCategory: e.budgetByCategory,
      );
}

extension WeddingAnalyticsDtoX on WeddingAnalyticsDto {
  WeddingAnalyticsEntity toEntity() => WeddingAnalyticsEntity(
        weddingId: weddingId,
        totalBudget: totalBudget,
        budgetUsed: budgetUsed,
        vendorsBooked: vendorsBooked,
        vendorsPending: vendorsPending,
        timelineCompletionRate: timelineCompletionRate,
        daysUntilWedding: daysUntilWedding,
        guestConfirmationRate: guestConfirmationRate,
        topExpenseCategory: topExpenseCategory,
        budgetByCategory: budgetByCategory,
      );
}
