import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/transaction_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class GetTransactionsUseCase
    implements UseCase<PaginatedResult<TransactionEntity>, GetTransactionsParams> {
  const GetTransactionsUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<TransactionEntity>>> call(
          GetTransactionsParams params) =>
      _repository.getTransactions(
        page: params.page,
        pageSize: params.pageSize,
        type: params.type,
      );
}

class GetTransactionsParams extends Equatable {
  const GetTransactionsParams({
    this.page = 1,
    this.pageSize = 20,
    this.type,
  });
  final int page;
  final int pageSize;
  final TransactionType? type;

  @override
  List<Object?> get props => [page, pageSize, type];
}
