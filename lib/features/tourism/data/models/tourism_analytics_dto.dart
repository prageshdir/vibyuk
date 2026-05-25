import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_analytics_entity.dart';

part 'tourism_analytics_dto.freezed.dart';
part 'tourism_analytics_dto.g.dart';

@freezed
class DestinationStatDto with _$DestinationStatDto {
  const factory DestinationStatDto({
    @JsonKey(name: 'destination_id') required String destinationId,
    @JsonKey(name: 'destination_name') required String destinationName,
    @Default(0) int reach,
    @JsonKey(name: 'engagement_rate', defaultValue: 0.0) required double engagementRate,
    @JsonKey(name: 'content_count', defaultValue: 0) required int contentCount,
    @JsonKey(name: 'creator_count', defaultValue: 0) required int creatorCount,
    @JsonKey(name: 'hero_image_url') String? heroImageUrl,
  }) = _DestinationStatDto;

  factory DestinationStatDto.fromJson(Map<String, dynamic> json) =>
      _$DestinationStatDtoFromJson(json);
}

extension DestinationStatDtoX on DestinationStatDto {
  DestinationStatEntity toEntity() => DestinationStatEntity(
        destinationId: destinationId,
        destinationName: destinationName,
        reach: reach,
        engagementRate: engagementRate,
        contentCount: contentCount,
        creatorCount: creatorCount,
        heroImageUrl: heroImageUrl,
      );
}

@freezed
class TourismAnalyticsDto with _$TourismAnalyticsDto {
  const factory TourismAnalyticsDto({
    @JsonKey(name: 'period_start') required String periodStart,
    @JsonKey(name: 'period_end') required String periodEnd,
    @JsonKey(name: 'total_destinations', defaultValue: 0) required int totalDestinations,
    @JsonKey(name: 'total_campaigns', defaultValue: 0) required int totalCampaigns,
    @JsonKey(name: 'active_campaigns', defaultValue: 0) required int activeCampaigns,
    @JsonKey(name: 'total_reach', defaultValue: 0) required int totalReach,
    @JsonKey(name: 'average_engagement_rate', defaultValue: 0.0) required double averageEngagementRate,
    @JsonKey(name: 'top_destinations', defaultValue: []) required List<DestinationStatDto> topDestinations,
    @JsonKey(name: 'total_creators', defaultValue: 0) required int totalCreators,
    @JsonKey(name: 'completed_fam_trips', defaultValue: 0) required int completedFamTrips,
    @JsonKey(name: 'content_pieces', defaultValue: 0) required int contentPieces,
    @JsonKey(name: 'reach_by_day', defaultValue: {}) required Map<String, int> reachByDay,
  }) = _TourismAnalyticsDto;

  factory TourismAnalyticsDto.fromJson(Map<String, dynamic> json) =>
      _$TourismAnalyticsDtoFromJson(json);
}

extension TourismAnalyticsDtoX on TourismAnalyticsDto {
  TourismAnalyticsEntity toEntity() => TourismAnalyticsEntity(
        periodStart: DateTime.parse(periodStart),
        periodEnd: DateTime.parse(periodEnd),
        totalDestinations: totalDestinations,
        totalCampaigns: totalCampaigns,
        activeCampaigns: activeCampaigns,
        totalReach: totalReach,
        averageEngagementRate: averageEngagementRate,
        topDestinations: topDestinations.map((d) => d.toEntity()).toList(),
        totalCreators: totalCreators,
        completedFamTrips: completedFamTrips,
        contentPieces: contentPieces,
        reachByDay: reachByDay,
      );
}
