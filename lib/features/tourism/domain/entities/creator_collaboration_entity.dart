import 'package:equatable/equatable.dart';

enum CollaborationStatus { pending, active, completed, cancelled }

class CreatorCollaborationEntity extends Equatable {
  const CreatorCollaborationEntity({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.destinationId,
    required this.status,
    required this.reach,
    required this.engagementRate,
    required this.contentUrls,
    required this.createdAt,
    this.creatorImageUrl,
    this.campaignId,
    this.agreedFee,
    this.completedAt,
  });

  final String id;
  final String creatorId;
  final String creatorName;
  final String? creatorImageUrl;
  final String destinationId;
  final String? campaignId;
  final CollaborationStatus status;
  final List<String> contentUrls;
  final int reach;
  final double engagementRate;
  final double? agreedFee;
  final DateTime? completedAt;
  final DateTime createdAt;

  bool get isActive => status == CollaborationStatus.active;

  String get formattedReach => reach > 1000000
      ? '${(reach / 1000000).toStringAsFixed(1)}M'
      : reach > 1000
          ? '${(reach / 1000).toStringAsFixed(0)}K'
          : reach.toString();

  @override
  List<Object?> get props => [
        id,
        creatorId,
        creatorName,
        creatorImageUrl,
        destinationId,
        campaignId,
        status,
        contentUrls,
        reach,
        engagementRate,
        agreedFee,
        completedAt,
        createdAt,
      ];
}
