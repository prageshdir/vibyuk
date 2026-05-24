import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';

abstract interface class PaymentRemoteDataSource {
  Future<Map<String, dynamic>> getPayments(int page, int pageSize,
      {String? status});
  Future<Map<String, dynamic>> getPaymentDetail(String paymentId);
  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required double amount,
    required String gateway,
  });
  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String signature,
    required String gateway,
  });
  Future<Map<String, dynamic>> getEscrowDetails(String bookingId);
  Future<Map<String, dynamic>> releaseEscrow({
    required String escrowId,
    String? milestoneId,
  });
  Future<Map<String, dynamic>> requestRefund({
    required String escrowId,
    required String reason,
  });
  Future<Map<String, dynamic>> getTransactions(int page, int pageSize,
      {String? type});
  Future<Map<String, dynamic>> getInvoice(String bookingId);
  Future<Map<String, dynamic>> getInvoicePdfUrl(String invoiceId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  Map<String, dynamic> _unwrap(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  @override
  Future<Map<String, dynamic>> getPayments(int page, int pageSize,
      {String? status}) async {
    final res = await _dio.get(
      ApiEndpoints.payments,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status,
      },
    );
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> getPaymentDetail(String paymentId) async {
    final res = await _dio.get(ApiEndpoints.payment(paymentId));
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required double amount,
    required String gateway,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.paymentInitiate,
      data: {
        'booking_id': bookingId,
        'amount': amount,
        'gateway': gateway,
      },
    );
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String signature,
    required String gateway,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.paymentVerify(paymentId),
      data: {
        'gateway_order_id': gatewayOrderId,
        'gateway_payment_id': gatewayPaymentId,
        'signature': signature,
        'gateway': gateway,
      },
    );
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> getEscrowDetails(String bookingId) async {
    final res = await _dio.get(ApiEndpoints.escrowByBooking(bookingId));
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> releaseEscrow({
    required String escrowId,
    String? milestoneId,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.escrowRelease(escrowId),
      data: {
        if (milestoneId != null) 'milestone_id': milestoneId,
      },
    );
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> requestRefund({
    required String escrowId,
    required String reason,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.escrowRefund(escrowId),
      data: {'reason': reason},
    );
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> getTransactions(int page, int pageSize,
      {String? type}) async {
    final res = await _dio.get(
      ApiEndpoints.transactions,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (type != null) 'type': type,
      },
    );
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> getInvoice(String bookingId) async {
    final res = await _dio.get(ApiEndpoints.invoiceByBooking(bookingId));
    return _unwrap(res);
  }

  @override
  Future<Map<String, dynamic>> getInvoicePdfUrl(String invoiceId) async {
    final res = await _dio.get(ApiEndpoints.invoicePdf(invoiceId));
    return _unwrap(res);
  }
}
