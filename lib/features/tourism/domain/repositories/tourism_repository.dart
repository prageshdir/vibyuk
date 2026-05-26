import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_analytics_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';

abstract interface class TourismRepository {
  // ── Destinations ─────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<TourismDestinationEntity>>>
      getDestinations({
    int page,
    int perPage,
    String? category,
    String? region,
    String? query,
    bool featuredOnly,
  });

  Future<Either<Failure, TourismDestinationEntity>> getDestinationDetail(
      String id);

  Future<Either<Failure, List<TourismDestinationEntity>>>
      getFeaturedDestinations();

  // ── Campaigns ────────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<TourismCampaignEntity>>>
      getCampaigns({
    int page,
    int perPage,
    String? destinationId,
    CampaignStatus? status,
  });

  Future<Either<Failure, TourismCampaignEntity>> getCampaignDetail(String id);

  Future<Either<Failure, TourismCampaignEntity>> createCampaign(
      Map<String, dynamic> data);

  Future<Either<Failure, TourismCampaignEntity>> updateCampaign(
      String id, Map<String, dynamic> data);

  // ── FAM Trips ────────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<FamTripEntity>>> getFamTrips({
    int page,
    int perPage,
    String? destinationId,
    FamTripStatus? status,
  });

  Future<Either<Failure, FamTripEntity>> getFamTripDetail(String id);

  Future<Either<Failure, Unit>> applyForFamTrip(
      String tripId, Map<String, dynamic> data);

  // ── Creator Collaborations ───────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<CreatorCollaborationEntity>>>
      getCollaborations({
    int page,
    int perPage,
    String? destinationId,
    String? campaignId,
  });

  Future<Either<Failure, CreatorCollaborationEntity>> createCollaboration(
      Map<String, dynamic> data);

  Future<Either<Failure, CreatorCollaborationEntity>> updateCollaboration(
      String id, Map<String, dynamic> data);

  // ── Analytics ────────────────────────────────────────────────────────────────
  Future<Either<Failure, TourismAnalyticsEntity>> getAnalytics({
    DateTime? from,
    DateTime? to,
  });
}
