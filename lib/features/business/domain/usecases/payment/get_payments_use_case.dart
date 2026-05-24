import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class GetPaymentsUseCase
    implements UseCase<PaginatedResult<PaymentEntity>, GetPaymentsParams> {
  GetPaymentsUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<PaymentEntity>>> call(GetPaymentsParams params) {
    return _repository.getPayments(page: params.page, pageSize: params.pageSize);
  }
}

class GetPaymentsParams extends Equatable {
  const GetPaymentsParams({this.page = 1, this.pageSize = 20});
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [page, pageSize];
}
