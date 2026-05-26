import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetPortfolioUseCase
    extends UseCase<PaginatedResult<PortfolioItemEntity>, GetPortfolioParams> {
  final CreatorRepository _repository;
  const GetPortfolioUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<PortfolioItemEntity>>> call(
          GetPortfolioParams params) =>
      _repository.getPortfolio(page: params.page, pageSize: params.pageSize);
}

class GetPortfolioParams extends Equatable {
  final int page;
  final int pageSize;
  const GetPortfolioParams({required this.page, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];
}
