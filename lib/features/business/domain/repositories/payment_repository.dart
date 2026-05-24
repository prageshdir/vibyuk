import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';

abstract interface class PaymentRepository {
  Future<Either<Failure, PaginatedResult<PaymentEntity>>> getPayments({
    required int page,
    int pageSize = 20,
  });

  Future<Either<Failure, PaymentEntity>> getPaymentDetail(String paymentId);
}
