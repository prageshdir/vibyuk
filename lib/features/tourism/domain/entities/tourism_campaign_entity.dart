import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';

enum CampaignStatus { draft, active, completed, paused }

class TourismCampaignEntity extends Equatable {
  const TourismCampaignEntity({
    required this.id,
    required this.title,
    required this.destinationId,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.targetCreatorCount,
    required this.enrolledCreatorCount,
    required this.budget,
    required this.reach,
    required this.engagementRate,
    required this.hashtags,
    required this.objectives,
    required this.galleryUrls,
    this.coverImageUrl,
    this.destination,
  });

  final String id;
  final String title;
  final String destinationId;
  final TourismDestinationEntity? destination;
  final String description;
  final String? coverImageUrl;
  final List<String> galleryUrls;
  final DateTime startDate;
  final DateTime endDate;
  final CampaignStatus status;
  final int targetCreatorCount;
  final int enrolledCreatorCount;
  final double budget;
  final int reach;
  final double engagementRate;
  final List<String> hashtags;
  final List<String> objectives;

  double get enrollmentProgress =>
      targetCreatorCount > 0
          ? (enrolledCreatorCount / targetCreatorCount).clamp(0.0, 1.0)
          : 0.0;

  int get daysRemaining =>
      endDate.difference(DateTime.now()).inDays.clamp(0, 99999);

  bool get isActive => status == CampaignStatus.active;

  String get formattedReach => reach > 1000000
      ? '${(reach / 1000000).toStringAsFixed(1)}M'
      : reach > 1000
          ? '${(reach / 1000).toStringAsFixed(0)}K'
          : reach.toString();

  @override
  List<Object?> get props => [
        id,
        title,
        destinationId,
        destination,
        description,
        coverImageUrl,
        galleryUrls,
        startDate,
        endDate,
        status,
        targetCreatorCount,
        enrolledCreatorCount,
        budget,
        reach,
        engagementRate,
        hashtags,
        objectives,
      ];
}
