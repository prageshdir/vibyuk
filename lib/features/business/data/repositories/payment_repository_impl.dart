import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/data/datasources/payment_remote_data_source.dart';
import 'package:vibyuk/features/business/data/models/payment_model.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl extends BaseRepository implements PaymentRepository {
  PaymentRepositoryImpl({required PaymentRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final PaymentRemoteDataSource _remote;

  PaginatedResult<PaymentEntity> _parsePaginated(Map<String, dynamic> data) {
    final items = (data['items'] as List? ?? data['data'] as List? ?? [])
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    return PaginatedResult<PaymentEntity>(
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
  }) =>
      safeCall(() async {
        final data = await _remote.getPayments(page, pageSize);
        return _parsePaginated(data);
      });

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentDetail(String paymentId) =>
      safeCall(() async {
        final data = await _remote.getPaymentDetail(paymentId);
        return PaymentModel.fromJson(data).toEntity();
      });
}
