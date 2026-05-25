import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/tourism/data/models/creator_collaboration_dto.dart';
import 'package:vibyuk/features/tourism/data/models/fam_trip_dto.dart';
import 'package:vibyuk/features/tourism/data/models/tourism_analytics_dto.dart';
import 'package:vibyuk/features/tourism/data/models/tourism_campaign_dto.dart';
import 'package:vibyuk/features/tourism/data/models/tourism_destination_dto.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_analytics_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';

abstract interface class TourismRemoteDataSource {
  Future<PaginatedResponse<TourismDestinationEntity>> getDestinations({
    int page,
    int perPage,
    String? category,
    String? region,
    String? query,
    bool featuredOnly,
  });

  Future<TourismDestinationEntity> getDestinationDetail(String id);

  Future<List<TourismDestinationEntity>> getFeaturedDestinations();

  Future<PaginatedResponse<TourismCampaignEntity>> getCampaigns({
    int page,
    int perPage,
    String? destinationId,
    CampaignStatus? status,
  });

  Future<TourismCampaignEntity> getCampaignDetail(String id);

  Future<TourismCampaignEntity> createCampaign(Map<String, dynamic> data);

  Future<TourismCampaignEntity> updateCampaign(
      String id, Map<String, dynamic> data);

  Future<PaginatedResponse<FamTripEntity>> getFamTrips({
    int page,
    int perPage,
    String? destinationId,
    FamTripStatus? status,
  });

  Future<FamTripEntity> getFamTripDetail(String id);

  Future<void> applyForFamTrip(String tripId, Map<String, dynamic> data);

  Future<PaginatedResponse<CreatorCollaborationEntity>> getCollaborations({
    int page,
    int perPage,
    String? destinationId,
    String? campaignId,
  });

  Future<CreatorCollaborationEntity> createCollaboration(
      Map<String, dynamic> data);

  Future<CreatorCollaborationEntity> updateCollaboration(
      String id, Map<String, dynamic> data);

  Future<TourismAnalyticsEntity> getAnalytics({
    DateTime? from,
    DateTime? to,
  });
}

class TourismRemoteDataSourceImpl implements TourismRemoteDataSource {
  const TourismRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResponse<TourismDestinationEntity>> getDestinations({
    int page = 1,
    int perPage = 20,
    String? category,
    String? region,
    String? query,
    bool featuredOnly = false,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.tourismDestinations,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (category != null) 'category': category,
        if (region != null) 'region': region,
        if (query != null) 'query': query,
        if (featuredOnly) 'featured_only': true,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((item) =>
            TourismDestinationDto.fromJson(item as Map<String, dynamic>)
                .toEntity())
        .toList();
    return PaginatedResponse.fromApiResponse(
        items: items, meta: body['meta'] as Map<String, dynamic>? ?? {});
  }

  @override
  Future<TourismDestinationEntity> getDestinationDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.tourismDestination(id));
    return TourismDestinationDto.fromJson(
            response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<List<TourismDestinationEntity>> getFeaturedDestinations() async {
    final response = await _dio.get(
      ApiEndpoints.tourismDestinations,
      queryParameters: {'featured_only': true, 'per_page': 10},
    );
    final body = response.data as Map<String, dynamic>;
    final items = body['data'] as List<dynamic>? ?? [];
    return items
        .map((item) =>
            TourismDestinationDto.fromJson(item as Map<String, dynamic>)
                .toEntity())
        .toList();
  }

  @override
  Future<PaginatedResponse<TourismCampaignEntity>> getCampaigns({
    int page = 1,
    int perPage = 20,
    String? destinationId,
    CampaignStatus? status,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.tourismCampaigns,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (destinationId != null) 'destination_id': destinationId,
        if (status != null) 'status': status.name,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((item) =>
            TourismCampaignDto.fromJson(item as Map<String, dynamic>).toEntity())
        .toList();
    return PaginatedResponse.fromApiResponse(
        items: items, meta: body['meta'] as Map<String, dynamic>? ?? {});
  }

  @override
  Future<TourismCampaignEntity> getCampaignDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.tourismCampaign(id));
    return TourismCampaignDto.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<TourismCampaignEntity> createCampaign(
      Map<String, dynamic> data) async {
    final response =
        await _dio.post(ApiEndpoints.tourismCampaigns, data: data);
    return TourismCampaignDto.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<TourismCampaignEntity> updateCampaign(
      String id, Map<String, dynamic> data) async {
    final response =
        await _dio.patch(ApiEndpoints.tourismCampaign(id), data: data);
    return TourismCampaignDto.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<PaginatedResponse<FamTripEntity>> getFamTrips({
    int page = 1,
    int perPage = 20,
    String? destinationId,
    FamTripStatus? status,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.famTrips,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (destinationId != null) 'destination_id': destinationId,
        if (status != null) 'status': status.name,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((item) =>
            FamTripDto.fromJson(item as Map<String, dynamic>).toEntity())
        .toList();
    return PaginatedResponse.fromApiResponse(
        items: items, meta: body['meta'] as Map<String, dynamic>? ?? {});
  }

  @override
  Future<FamTripEntity> getFamTripDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.famTrip(id));
    return FamTripDto.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<void> applyForFamTrip(
      String tripId, Map<String, dynamic> data) async {
    await _dio.post(ApiEndpoints.applyFamTrip(tripId), data: data);
  }

  @override
  Future<PaginatedResponse<CreatorCollaborationEntity>> getCollaborations({
    int page = 1,
    int perPage = 20,
    String? destinationId,
    String? campaignId,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.tourismCollaborations,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (destinationId != null) 'destination_id': destinationId,
        if (campaignId != null) 'campaign_id': campaignId,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final items = (body['data'] as List<dynamic>? ?? [])
        .map((item) => CreatorCollaborationDto.fromJson(
                item as Map<String, dynamic>)
            .toEntity())
        .toList();
    return PaginatedResponse.fromApiResponse(
        items: items, meta: body['meta'] as Map<String, dynamic>? ?? {});
  }

  @override
  Future<CreatorCollaborationEntity> createCollaboration(
      Map<String, dynamic> data) async {
    final response =
        await _dio.post(ApiEndpoints.tourismCollaborations, data: data);
    return CreatorCollaborationDto.fromJson(
            response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<CreatorCollaborationEntity> updateCollaboration(
      String id, Map<String, dynamic> data) async {
    final response =
        await _dio.patch(ApiEndpoints.tourismCollaboration(id), data: data);
    return CreatorCollaborationDto.fromJson(
            response.data as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<TourismAnalyticsEntity> getAnalytics({
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.tourismAnalytics,
      queryParameters: {
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
    );
    return TourismAnalyticsDto.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }
}
