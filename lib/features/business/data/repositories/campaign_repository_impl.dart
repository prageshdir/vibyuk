import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/data/datasources/campaign_remote_data_source.dart';
import 'package:vibyuk/features/business/data/dtos/create_campaign_dto.dart';
import 'package:vibyuk/features/business/data/dtos/update_campaign_dto.dart';
import 'package:vibyuk/features/business/data/models/campaign_model.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/repositories/campaign_repository.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/create_campaign_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/update_campaign_use_case.dart';

class CampaignRepositoryImpl extends BaseRepository implements CampaignRepository {
  CampaignRepositoryImpl({required CampaignRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final CampaignRemoteDataSource _remote;

  PaginatedResult<CampaignEntity> _parsePaginated(Map<String, dynamic> data) {
    final items = (data['items'] as List? ?? data['data'] as List? ?? [])
        .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    return PaginatedResult<CampaignEntity>(
      items: items,
      currentPage: data['current_page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
      totalItems: data['total_items'] as int? ?? items.length,
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<CampaignEntity>>> getCampaigns({
    CampaignStatus? status,
    required int page,
    int pageSize = 20,
  }) =>
      safeCall(() async {
        final data = await _remote.getCampaigns(
            status: status, page: page, pageSize: pageSize);
        return _parsePaginated(data);
      });

  @override
  Future<Either<Failure, CampaignEntity>> getCampaignDetail(String campaignId) =>
      safeCall(() async {
        final data = await _remote.getCampaignDetail(campaignId);
        return CampaignModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, CampaignEntity>> createCampaign({
    required String title,
    String? description,
    required double budget,
    CampaignType campaignType = CampaignType.standard,
    required DateTime startDate,
    DateTime? endDate,
    required List<String> categories,
    int targetCreatorCount = 1,
  }) =>
      safeCall(() async {
        final dto = CreateCampaignDto.fromParams(CreateCampaignParams(
          title: title,
          description: description,
          budget: budget,
          campaignType: campaignType,
          startDate: startDate,
          endDate: endDate,
          categories: categories,
          targetCreatorCount: targetCreatorCount,
        ));
        final data = await _remote.createCampaign(dto);
        return CampaignModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, CampaignEntity>> updateCampaign({
    required String campaignId,
    String? title,
    String? description,
    double? budget,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categories,
    int? targetCreatorCount,
  }) =>
      safeCall(() async {
        final dto = UpdateCampaignDto.fromParams(UpdateCampaignParams(
          campaignId: campaignId,
          title: title,
          description: description,
          budget: budget,
          startDate: startDate,
          endDate: endDate,
          categories: categories,
          targetCreatorCount: targetCreatorCount,
        ));
        final data = await _remote.updateCampaign(campaignId, dto);
        return CampaignModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, Unit>> deleteCampaign(String campaignId) =>
      safeCall(() async {
        await _remote.deleteCampaign(campaignId);
        return unit;
      });

  @override
  Future<Either<Failure, CampaignEntity>> publishCampaign(String campaignId) =>
      safeCall(() async {
        final data = await _remote.publishCampaign(campaignId);
        return CampaignModel.fromJson(data).toEntity();
      });
}
