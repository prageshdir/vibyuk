import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';

abstract interface class DiscoveryRemoteDataSource {
  Future<Map<String, dynamic>> searchCreators(Map<String, dynamic> queryParams);
  Future<Map<String, dynamic>> getCreatorDetail(String creatorId);
  Future<void> saveCreator(String creatorId);
  Future<void> unsaveCreator(String creatorId);
  Future<Map<String, dynamic>> getSavedCreators(int page, int pageSize);
  Future<List<dynamic>> getFeaturedCreators();
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  DiscoveryRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  List<dynamic> _dataList(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is List) {
      return body['data'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> searchCreators(
      Map<String, dynamic> queryParams) async {
    final response = await _dio.get(
      ApiEndpoints.searchCreators,
      queryParameters: queryParams,
    );
    return _data(response);
  }

  @override
  Future<Map<String, dynamic>> getCreatorDetail(String creatorId) async {
    final response = await _dio.get(ApiEndpoints.creator(creatorId));
    return _data(response);
  }

  @override
  Future<void> saveCreator(String creatorId) async {
    await _dio.post('${ApiEndpoints.creator(creatorId)}/save');
  }

  @override
  Future<void> unsaveCreator(String creatorId) async {
    await _dio.delete('${ApiEndpoints.creator(creatorId)}/save');
  }

  @override
  Future<Map<String, dynamic>> getSavedCreators(int page, int pageSize) async {
    final response = await _dio.get(
      '${ApiEndpoints.creators}/saved',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return _data(response);
  }

  @override
  Future<List<dynamic>> getFeaturedCreators() async {
    final response = await _dio.get('${ApiEndpoints.creators}/featured');
    return _dataList(response);
  }
}
