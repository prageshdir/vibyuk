import 'package:vibyuk/core/api/api_client.dart';
import 'package:vibyuk/features/subscriptions/data/dtos/subscription_dto.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';

abstract interface class SubscriptionRemoteDataSource {
  Future<SubscriptionDto> getSubscription();
  Future<RazorpayOrderDto> createPaymentOrder(SubscriptionPlan plan);
  Future<SubscriptionDto> verifyAndActivate({
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
    required SubscriptionPlan plan,
  });
  Future<void> cancelSubscription();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<SubscriptionDto> getSubscription() async {
    final response = await _client.get('/subscriptions/me');
    final data = response.data as Map<String, dynamic>;
    return SubscriptionDto.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<RazorpayOrderDto> createPaymentOrder(SubscriptionPlan plan) async {
    final response = await _client.post(
      '/subscriptions/orders',
      data: {'plan': plan.serverValue},
    );
    final data = response.data as Map<String, dynamic>;
    return RazorpayOrderDto.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SubscriptionDto> verifyAndActivate({
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
    required SubscriptionPlan plan,
  }) async {
    final response = await _client.post(
      '/subscriptions/verify',
      data: {
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': signature,
        'plan': plan.serverValue,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return SubscriptionDto.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> cancelSubscription() async {
    await _client.delete('/subscriptions/me');
  }
}
