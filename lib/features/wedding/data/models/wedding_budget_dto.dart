import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';

part 'wedding_budget_dto.freezed.dart';
part 'wedding_budget_dto.g.dart';

@freezed
class WeddingBudgetItemDto with _$WeddingBudgetItemDto {
  const factory WeddingBudgetItemDto({
    required String id,
    @JsonKey(name: 'wedding_id') required String weddingId,
    required String category,
    required String description,
    @JsonKey(name: 'estimated_amount') required double estimatedAmount,
    @JsonKey(name: 'actual_amount') @Default(0.0) double actualAmount,
    @JsonKey(name: 'is_paid') @Default(false) bool isPaid,
    @JsonKey(name: 'vendor_id') String? vendorId,
    String? notes,
  }) = _WeddingBudgetItemDto;

  factory WeddingBudgetItemDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingBudgetItemDtoFromJson(json);

  factory WeddingBudgetItemDto.fromEntity(WeddingBudgetItemEntity e) =>
      WeddingBudgetItemDto(
        id: e.id,
        weddingId: e.weddingId,
        category: e.category,
        description: e.description,
        estimatedAmount: e.estimatedAmount,
        actualAmount: e.actualAmount,
        isPaid: e.isPaid,
        vendorId: e.vendorId,
        notes: e.notes,
      );
}

extension WeddingBudgetItemDtoX on WeddingBudgetItemDto {
  WeddingBudgetItemEntity toEntity() => WeddingBudgetItemEntity(
        id: id,
        weddingId: weddingId,
        category: category,
        description: description,
        estimatedAmount: estimatedAmount,
        actualAmount: actualAmount,
        isPaid: isPaid,
        vendorId: vendorId,
        notes: notes,
      );
}

@freezed
class WeddingBudgetDto with _$WeddingBudgetDto {
  const factory WeddingBudgetDto({
    @JsonKey(name: 'wedding_id') required String weddingId,
    @JsonKey(name: 'total_budget') required double totalBudget,
    @Default([]) List<WeddingBudgetItemDto> items,
  }) = _WeddingBudgetDto;

  factory WeddingBudgetDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingBudgetDtoFromJson(json);

  factory WeddingBudgetDto.fromEntity(WeddingBudgetEntity e) => WeddingBudgetDto(
        weddingId: e.weddingId,
        totalBudget: e.totalBudget,
        items: e.items.map(WeddingBudgetItemDto.fromEntity).toList(),
      );
}

extension WeddingBudgetDtoX on WeddingBudgetDto {
  WeddingBudgetEntity toEntity() => WeddingBudgetEntity(
        weddingId: weddingId,
        totalBudget: totalBudget,
        items: items.map((i) => i.toEntity()).toList(),
      );
}
