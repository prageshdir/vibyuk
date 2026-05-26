import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/tourism/data/datasources/tourism_local_datasource.dart';
import 'package:vibyuk/features/tourism/data/datasources/tourism_remote_datasource.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_analytics_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class TourismRepositoryImpl extends BaseRepository implements TourismRepository {
  const TourismRepositoryImpl({
    required TourismLocalDataSource local,
    required TourismRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final TourismLocalDataSource _local;
  final TourismRemoteDataSource _remote;

  // ── Destinations ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<TourismDestinationEntity>>>
      getDestinations({
    int page = 1,
    int perPage = 20,
    String? category,
    String? region,
    String? query,
    bool featuredOnly = false,
  }) async {
    if (page == 1 && query == null) {
      final cached = await _local.getDestinations(
        category: category,
        region: region,
        featuredOnly: featuredOnly,
      );
      if (cached.isNotEmpty) {
        _syncDestinations(
          page: page,
          perPage: perPage,
          category: category,
          region: region,
          query: query,
          featuredOnly: featuredOnly,
        );
        return Right(PaginatedResponse(
          items: cached,
          currentPage: 1,
          totalPages: 1,
          totalItems: cached.length,
          perPage: perPage,
        ));
      }
    }
    return safeCall(
      () async {
        final result = await _remote.getDestinations(
          page: page,
          perPage: perPage,
          category: category,
          region: region,
          query: query,
          featuredOnly: featuredOnly,
        );
        for (final dest in result.items) {
          await _local.cacheDestination(dest);
        }
        return result;
      },
      context: 'TourismRepository.getDestinations',
    );
  }

  void _syncDestinations({
    required int page,
    required int perPage,
    String? category,
    String? region,
    String? query,
    required bool featuredOnly,
  }) {
    _remote
        .getDestinations(
          page: page,
          perPage: perPage,
          category: category,
          region: region,
          query: query,
          featuredOnly: featuredOnly,
        )
        .then((result) async {
      for (final dest in result.items) {
        await _local.cacheDestination(dest);
      }
    }).ignore();
  }

  @override
  Future<Either<Failure, TourismDestinationEntity>> getDestinationDetail(
      String id) async {
    final cached = await _local.getDestination(id);
    if (cached != null) {
      _remote
          .getDestinationDetail(id)
          .then((fresh) => _local.cacheDestination(fresh))
          .ignore();
      return Right(cached);
    }
    return safeCall(
      () async {
        final result = await _remote.getDestinationDetail(id);
        await _local.cacheDestination(result);
        return result;
      },
      context: 'TourismRepository.getDestinationDetail',
    );
  }

  @override
  Future<Either<Failure, List<TourismDestinationEntity>>>
      getFeaturedDestinations() async {
    final cached =
        await _local.getDestinations(featuredOnly: true);
    if (cached.isNotEmpty) {
      _remote
          .getFeaturedDestinations()
          .then((fresh) async {
        for (final d in fresh) {
          await _local.cacheDestination(d);
        }
      }).ignore();
      return Right(cached);
    }
    return safeCall(
      () async {
        final result = await _remote.getFeaturedDestinations();
        for (final d in result) {
          await _local.cacheDestination(d);
        }
        return result;
      },
      context: 'TourismRepository.getFeaturedDestinations',
    );
  }

  // ── Campaigns ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<TourismCampaignEntity>>> getCampaigns({
    int page = 1,
    int perPage = 20,
    String? destinationId,
    CampaignStatus? status,
  }) async {
    if (page == 1) {
      final cached = await _local.getCampaigns(
        destinationId: destinationId,
        status: status?.name,
      );
      if (cached.isNotEmpty) {
        _remote
            .getCampaigns(
              page: page,
              perPage: perPage,
              destinationId: destinationId,
              status: status,
            )
            .then((result) async {
          for (final c in result.items) {
            await _local.cacheCampaign(c);
          }
        }).ignore();
        return Right(PaginatedResponse(
          items: cached,
          currentPage: 1,
          totalPages: 1,
          totalItems: cached.length,
          perPage: perPage,
        ));
      }
    }
    return safeCall(
      () async {
        final result = await _remote.getCampaigns(
          page: page,
          perPage: perPage,
          destinationId: destinationId,
          status: status,
        );
        for (final c in result.items) {
          await _local.cacheCampaign(c);
        }
        return result;
      },
      context: 'TourismRepository.getCampaigns',
    );
  }

  @override
  Future<Either<Failure, TourismCampaignEntity>> getCampaignDetail(
      String id) async {
    final cached = await _local.getCampaign(id);
    if (cached != null) {
      _remote
          .getCampaignDetail(id)
          .then((fresh) => _local.cacheCampaign(fresh))
          .ignore();
      return Right(cached);
    }
    return safeCall(
      () async {
        final result = await _remote.getCampaignDetail(id);
        await _local.cacheCampaign(result);
        return result;
      },
      context: 'TourismRepository.getCampaignDetail',
    );
  }

  @override
  Future<Either<Failure, TourismCampaignEntity>> createCampaign(
      Map<String, dynamic> data) {
    return safeCall(
      () async {
        final result = await _remote.createCampaign(data);
        await _local.cacheCampaign(result);
        return result;
      },
      context: 'TourismRepository.createCampaign',
    );
  }

  @override
  Future<Either<Failure, TourismCampaignEntity>> updateCampaign(
      String id, Map<String, dynamic> data) {
    return safeCall(
      () async {
        final result = await _remote.updateCampaign(id, data);
        await _local.cacheCampaign(result);
        return result;
      },
      context: 'TourismRepository.updateCampaign',
    );
  }

  // ── FAM Trips ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<FamTripEntity>>> getFamTrips({
    int page = 1,
    int perPage = 20,
    String? destinationId,
    FamTripStatus? status,
  }) {
    return safeCall(
      () => _remote.getFamTrips(
        page: page,
        perPage: perPage,
        destinationId: destinationId,
        status: status,
      ),
      context: 'TourismRepository.getFamTrips',
    );
  }

  @override
  Future<Either<Failure, FamTripEntity>> getFamTripDetail(String id) {
    return safeCall(
      () => _remote.getFamTripDetail(id),
      context: 'TourismRepository.getFamTripDetail',
    );
  }

  @override
  Future<Either<Failure, Unit>> applyForFamTrip(
      String tripId, Map<String, dynamic> data) {
    return safeCall(
      () async {
        await _remote.applyForFamTrip(tripId, data);
        return unit;
      },
      context: 'TourismRepository.applyForFamTrip',
    );
  }

  // ── Creator Collaborations ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<CreatorCollaborationEntity>>>
      getCollaborations({
    int page = 1,
    int perPage = 20,
    String? destinationId,
    String? campaignId,
  }) {
    return safeCall(
      () => _remote.getCollaborations(
        page: page,
        perPage: perPage,
        destinationId: destinationId,
        campaignId: campaignId,
      ),
      context: 'TourismRepository.getCollaborations',
    );
  }

  @override
  Future<Either<Failure, CreatorCollaborationEntity>> createCollaboration(
      Map<String, dynamic> data) {
    return safeCall(
      () => _remote.createCollaboration(data),
      context: 'TourismRepository.createCollaboration',
    );
  }

  @override
  Future<Either<Failure, CreatorCollaborationEntity>> updateCollaboration(
      String id, Map<String, dynamic> data) {
    return safeCall(
      () => _remote.updateCollaboration(id, data),
      context: 'TourismRepository.updateCollaboration',
    );
  }

  // ── Analytics ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, TourismAnalyticsEntity>> getAnalytics({
    DateTime? from,
    DateTime? to,
  }) async {
    final cached = await _local.getCachedAnalytics();
    if (cached != null) {
      _remote
          .getAnalytics(from: from, to: to)
          .then((fresh) => _local.cacheAnalytics(fresh))
          .ignore();
      return Right(cached);
    }
    return safeCall(
      () async {
        final result = await _remote.getAnalytics(from: from, to: to);
        await _local.cacheAnalytics(result);
        return result;
      },
      context: 'TourismRepository.getAnalytics',
    );
  }
}
