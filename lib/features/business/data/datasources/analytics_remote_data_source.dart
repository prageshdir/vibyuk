import 'package:dio/dio.dart';

abstract interface class AnalyticsRemoteDataSource {
  Future<Map<String, dynamic>> getAnalyticsDashboard(String period);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<Map<String, dynamic>> getAnalyticsDashboard(String period) async {
    final response = await _dio.get(
      '/analytics/dashboard',
      queryParameters: {'period': period},
    );
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }
}
