import 'package:equatable/equatable.dart';

class DestinationStatEntity extends Equatable {
  const DestinationStatEntity({
    required this.destinationId,
    required this.destinationName,
    required this.reach,
    required this.engagementRate,
    required this.contentCount,
    required this.creatorCount,
    this.heroImageUrl,
  });

  final String destinationId;
  final String destinationName;
  final int reach;
  final double engagementRate;
  final int contentCount;
  final int creatorCount;
  final String? heroImageUrl;

  String get formattedReach => reach > 1000000
      ? '${(reach / 1000000).toStringAsFixed(1)}M'
      : reach > 1000
          ? '${(reach / 1000).toStringAsFixed(0)}K'
          : reach.toString();

  @override
  List<Object?> get props => [
        destinationId,
        destinationName,
        reach,
        engagementRate,
        contentCount,
        creatorCount,
      ];
}

class TourismAnalyticsEntity extends Equatable {
  const TourismAnalyticsEntity({
    required this.periodStart,
    required this.periodEnd,
    required this.totalDestinations,
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.totalReach,
    required this.averageEngagementRate,
    required this.topDestinations,
    required this.totalCreators,
    required this.completedFamTrips,
    required this.contentPieces,
    required this.reachByDay,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalDestinations;
  final int totalCampaigns;
  final int activeCampaigns;
  final int totalReach;
  final double averageEngagementRate;
  final List<DestinationStatEntity> topDestinations;
  final int totalCreators;
  final int completedFamTrips;
  final int contentPieces;
  final Map<String, int> reachByDay;

  String get formattedReach => totalReach > 1000000
      ? '${(totalReach / 1000000).toStringAsFixed(1)}M'
      : totalReach > 1000
          ? '${(totalReach / 1000).toStringAsFixed(0)}K'
          : totalReach.toString();

  @override
  List<Object?> get props => [
        periodStart,
        periodEnd,
        totalDestinations,
        totalCampaigns,
        activeCampaigns,
        totalReach,
        averageEngagementRate,
        topDestinations,
        totalCreators,
        completedFamTrips,
        contentPieces,
        reachByDay,
      ];
}
