import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';

part 'creator_collaboration_dto.freezed.dart';
part 'creator_collaboration_dto.g.dart';

@freezed
class CreatorCollaborationDto with _$CreatorCollaborationDto {
  const factory CreatorCollaborationDto({
    required String id,
    @JsonKey(name: 'creator_id') required String creatorId,
    @JsonKey(name: 'creator_name') required String creatorName,
    @JsonKey(name: 'creator_image_url') String? creatorImageUrl,
    @JsonKey(name: 'destination_id') required String destinationId,
    @JsonKey(name: 'campaign_id') String? campaignId,
    required String status,
    @JsonKey(name: 'content_urls', defaultValue: []) required List<String> contentUrls,
    @Default(0) int reach,
    @JsonKey(name: 'engagement_rate', defaultValue: 0.0) required double engagementRate,
    @JsonKey(name: 'agreed_fee') double? agreedFee,
    @JsonKey(name: 'completed_at') String? completedAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _CreatorCollaborationDto;

  factory CreatorCollaborationDto.fromJson(Map<String, dynamic> json) =>
      _$CreatorCollaborationDtoFromJson(json);

  factory CreatorCollaborationDto.fromEntity(CreatorCollaborationEntity entity) =>
      CreatorCollaborationDto(
        id: entity.id,
        creatorId: entity.creatorId,
        creatorName: entity.creatorName,
        creatorImageUrl: entity.creatorImageUrl,
        destinationId: entity.destinationId,
        campaignId: entity.campaignId,
        status: entity.status.name,
        contentUrls: entity.contentUrls,
        reach: entity.reach,
        engagementRate: entity.engagementRate,
        agreedFee: entity.agreedFee,
        completedAt: entity.completedAt?.toIso8601String(),
        createdAt: entity.createdAt.toIso8601String(),
      );
}

extension CreatorCollaborationDtoX on CreatorCollaborationDto {
  CreatorCollaborationEntity toEntity() => CreatorCollaborationEntity(
        id: id,
        creatorId: creatorId,
        creatorName: creatorName,
        creatorImageUrl: creatorImageUrl,
        destinationId: destinationId,
        campaignId: campaignId,
        status: CollaborationStatus.values.byName(status),
        contentUrls: contentUrls,
        reach: reach,
        engagementRate: engagementRate,
        agreedFee: agreedFee,
        completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
        createdAt: DateTime.parse(createdAt),
      );
}
