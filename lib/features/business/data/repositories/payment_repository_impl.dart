import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/data/datasources/payment_remote_data_source.dart';
import 'package:vibyuk/features/business/data/models/escrow_model.dart';
import 'package:vibyuk/features/business/data/models/invoice_model.dart';
import 'package:vibyuk/features/business/data/models/payment_analytics_model.dart';
import 'package:vibyuk/features/business/data/models/payment_model.dart';
import 'package:vibyuk/features/business/data/models/payment_order_model.dart';
import 'package:vibyuk/features/business/data/models/transaction_model.dart';
import 'package:vibyuk/features/business/domain/entities/escrow_entity.dart';
import 'package:vibyuk/features/business/domain/entities/invoice_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/payment_analytics_entity.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/domain/entities/payment_order_entity.dart';
import 'package:vibyuk/features/business/domain/entities/transaction_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl extends BaseRepository implements PaymentRepository {
  PaymentRepositoryImpl({required PaymentRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final PaymentRemoteDataSource _remote;

  PaginatedResult<T> _parsePaginated<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = (data['items'] as List? ?? data['data'] as List? ?? [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginatedResult<T>(
      items: items,
      currentPage: data['current_page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
      totalItems: data['total_items'] as int? ?? items.length,
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<PaymentEntity>>> getPayments({
    required int page,
    int pageSize = 20,
    PaymentStatus? status,
  }) =>
      safeCall(() async {
        final data = await _remote.getPayments(page, pageSize,
            status: status?.name);
        return _parsePaginated(
            data, (j) => PaymentModel.fromJson(j).toEntity());
      });

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentDetail(String paymentId) =>
      safeCall(() async {
        final data = await _remote.getPaymentDetail(paymentId);
        return PaymentModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, PaymentOrderEntity>> initiatePayment({
    required String bookingId,
    required double amount,
    required PaymentGateway gateway,
  }) =>
      safeCall(() async {
        final data = await _remote.initiatePayment(
          bookingId: bookingId,
          amount: amount,
          gateway: gateway.name,
        );
        return PaymentOrderModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, PaymentEntity>> verifyPayment({
    required String paymentId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String signature,
    required PaymentGateway gateway,
  }) =>
      safeCall(() async {
        final data = await _remote.verifyPayment(
          paymentId: paymentId,
          gatewayOrderId: gatewayOrderId,
          gatewayPaymentId: gatewayPaymentId,
          signature: signature,
          gateway: gateway.name,
        );
        return PaymentModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, EscrowEntity>> getEscrowDetails(String bookingId) =>
      safeCall(() async {
        final data = await _remote.getEscrowDetails(bookingId);
        return EscrowModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, EscrowEntity>> releaseEscrow({
    required String escrowId,
    String? milestoneId,
  }) =>
      safeCall(() async {
        final data = await _remote.releaseEscrow(
          escrowId: escrowId,
          milestoneId: milestoneId,
        );
        return EscrowModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, EscrowEntity>> requestRefund({
    required String escrowId,
    required String reason,
  }) =>
      safeCall(() async {
        final data =
            await _remote.requestRefund(escrowId: escrowId, reason: reason);
        return EscrowModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, PaginatedResult<TransactionEntity>>> getTransactions({
    required int page,
    int pageSize = 20,
    TransactionType? type,
  }) =>
      safeCall(() async {
        final data =
            await _remote.getTransactions(page, pageSize, type: type?.name);
        return _parsePaginated(
            data, (j) => TransactionModel.fromJson(j).toEntity());
      });

  @override
  Future<Either<Failure, InvoiceEntity>> getInvoice(String bookingId) =>
      safeCall(() async {
        final data = await _remote.getInvoice(bookingId);
        return InvoiceModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, String>> getInvoicePdfUrl(String invoiceId) =>
      safeCall(() async {
        final data = await _remote.getInvoicePdfUrl(invoiceId);
        return data['url'] as String;
      });

  @override
  Future<Either<Failure, PaymentAnalyticsEntity>> getPaymentAnalytics({
    String period = '30d',
  }) =>
      safeCall(() async {
        final data = await _remote.getPaymentAnalytics(period);
        return PaymentAnalyticsModel.fromJson(data).toEntity();
      });
}
