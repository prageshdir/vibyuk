import 'package:dio/dio.dart';

abstract interface class PaymentRemoteDataSource {
  Future<Map<String, dynamic>> getPayments(int page, int pageSize);
  Future<Map<String, dynamic>> getPaymentDetail(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  static const _basePath = '/payments';

  Map<String, dynamic> _data(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  @override
  Future<Map<String, dynamic>> getPayments(int page, int pageSize) async {
    final response = await _dio.get(_basePath, queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    return _data(response);
  }

  @override
  Future<Map<String, dynamic>> getPaymentDetail(String paymentId) async {
    final response = await _dio.get('$_basePath/$paymentId');
    return _data(response);
  }
}
