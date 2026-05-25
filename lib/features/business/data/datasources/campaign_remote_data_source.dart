import 'package:dio/dio.dart';
import 'package:vibyuk/features/business/data/dtos/create_campaign_dto.dart';
import 'package:vibyuk/features/business/data/dtos/update_campaign_dto.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';

abstract interface class CampaignRemoteDataSource {
  Future<Map<String, dynamic>> getCampaigns(
      {CampaignStatus? status, required int page, required int pageSize});
  Future<Map<String, dynamic>> getCampaignDetail(String campaignId);
  Future<Map<String, dynamic>> createCampaign(CreateCampaignDto dto);
  Future<Map<String, dynamic>> updateCampaign(
      String campaignId, UpdateCampaignDto dto);
  Future<void> deleteCampaign(String campaignId);
  Future<Map<String, dynamic>> publishCampaign(String campaignId);
}

class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  CampaignRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  static const _basePath = '/campaigns';

  Map<String, dynamic> _data(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  @override
  Future<Map<String, dynamic>> getCampaigns(
      {CampaignStatus? status, required int page, required int pageSize}) async {
    final response = await _dio.get(_basePath, queryParameters: {
      if (status != null) 'status': status.name,
      'page': page,
      'page_size': pageSize,
    });
    return _data(response);
  }

  @override
  Future<Map<String, dynamic>> getCampaignDetail(String campaignId) async {
    final response = await _dio.get('$_basePath/$campaignId');
    return _data(response);
  }

  @override
  Future<Map<String, dynamic>> createCampaign(CreateCampaignDto dto) async {
    final response = await _dio.post(_basePath, data: dto.toJson());
    return _data(response);
  }

  @override
  Future<Map<String, dynamic>> updateCampaign(
      String campaignId, UpdateCampaignDto dto) async {
    final response =
        await _dio.patch('$_basePath/$campaignId', data: dto.toJson());
    return _data(response);
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    await _dio.delete('$_basePath/$campaignId');
  }

  @override
  Future<Map<String, dynamic>> publishCampaign(String campaignId) async {
    final response = await _dio.post('$_basePath/$campaignId/publish');
    return _data(response);
  }
}
