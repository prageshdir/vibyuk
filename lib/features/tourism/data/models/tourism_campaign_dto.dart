import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';

part 'tourism_campaign_dto.freezed.dart';
part 'tourism_campaign_dto.g.dart';

@freezed
class TourismCampaignDto with _$TourismCampaignDto {
  const factory TourismCampaignDto({
    required String id,
    required String title,
    @JsonKey(name: 'destination_id') required String destinationId,
    required String description,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'gallery_urls', defaultValue: []) required List<String> galleryUrls,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    required String status,
    @JsonKey(name: 'target_creator_count', defaultValue: 0) required int targetCreatorCount,
    @JsonKey(name: 'enrolled_creator_count', defaultValue: 0) required int enrolledCreatorCount,
    @Default(0.0) double budget,
    @Default(0) int reach,
    @JsonKey(name: 'engagement_rate', defaultValue: 0.0) required double engagementRate,
    @JsonKey(defaultValue: []) required List<String> hashtags,
    @JsonKey(defaultValue: []) required List<String> objectives,
  }) = _TourismCampaignDto;

  factory TourismCampaignDto.fromJson(Map<String, dynamic> json) =>
      _$TourismCampaignDtoFromJson(json);

  factory TourismCampaignDto.fromEntity(TourismCampaignEntity entity) =>
      TourismCampaignDto(
        id: entity.id,
        title: entity.title,
        destinationId: entity.destinationId,
        description: entity.description,
        coverImageUrl: entity.coverImageUrl,
        galleryUrls: entity.galleryUrls,
        startDate: entity.startDate.toIso8601String(),
        endDate: entity.endDate.toIso8601String(),
        status: entity.status.name,
        targetCreatorCount: entity.targetCreatorCount,
        enrolledCreatorCount: entity.enrolledCreatorCount,
        budget: entity.budget,
        reach: entity.reach,
        engagementRate: entity.engagementRate,
        hashtags: entity.hashtags,
        objectives: entity.objectives,
      );
}

extension TourismCampaignDtoX on TourismCampaignDto {
  TourismCampaignEntity toEntity() => TourismCampaignEntity(
        id: id,
        title: title,
        destinationId: destinationId,
        description: description,
        coverImageUrl: coverImageUrl,
        galleryUrls: galleryUrls,
        startDate: DateTime.parse(startDate),
        endDate: DateTime.parse(endDate),
        status: CampaignStatus.values.byName(status),
        targetCreatorCount: targetCreatorCount,
        enrolledCreatorCount: enrolledCreatorCount,
        budget: budget,
        reach: reach,
        engagementRate: engagementRate,
        hashtags: hashtags,
        objectives: objectives,
      );
}
