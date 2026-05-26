import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';

part 'wedding_dto.freezed.dart';
part 'wedding_dto.g.dart';

@freezed
class WeddingDto with _$WeddingDto {
  const factory WeddingDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'your_name') required String yourName,
    @JsonKey(name: 'partner_name') required String partnerName,
    @JsonKey(name: 'wedding_date') required String weddingDate,
    @JsonKey(name: 'total_budget') required double totalBudget,
    @JsonKey(name: 'estimated_guest_count') required int estimatedGuestCount,
    @JsonKey(name: 'actual_guest_count') @Default(0) int actualGuestCount,
    @Default('planning') String status,
    @JsonKey(name: 'venue_name') String? venueName,
    String? theme,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _WeddingDto;

  factory WeddingDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingDtoFromJson(json);

  factory WeddingDto.fromEntity(WeddingEntity e) => WeddingDto(
        id: e.id,
        userId: e.userId,
        yourName: e.yourName,
        partnerName: e.partnerName,
        weddingDate: e.weddingDate.toIso8601String(),
        totalBudget: e.totalBudget,
        estimatedGuestCount: e.estimatedGuestCount,
        actualGuestCount: e.actualGuestCount,
        status: e.status.name,
        venueName: e.venueName,
        theme: e.theme,
        createdAt: e.createdAt.toIso8601String(),
        updatedAt: e.updatedAt.toIso8601String(),
      );
}

extension WeddingDtoX on WeddingDto {
  WeddingEntity toEntity() => WeddingEntity(
        id: id,
        userId: userId,
        yourName: yourName,
        partnerName: partnerName,
        weddingDate: DateTime.parse(weddingDate),
        totalBudget: totalBudget,
        estimatedGuestCount: estimatedGuestCount,
        actualGuestCount: actualGuestCount,
        status: _parseStatus(status),
        venueName: venueName,
        theme: theme,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );

  WeddingStatus _parseStatus(String s) => switch (s) {
        'confirmed' => WeddingStatus.confirmed,
        'completed' => WeddingStatus.completed,
        _ => WeddingStatus.planning,
      };
}
