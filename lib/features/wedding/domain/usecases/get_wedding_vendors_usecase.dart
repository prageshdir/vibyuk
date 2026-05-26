import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/network/paginated_response.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class GetWeddingVendorsUseCase
    extends UseCase<PaginatedResponse<WeddingVendorEntity>, GetWeddingVendorsParams> {
  const GetWeddingVendorsUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<WeddingVendorEntity>>> call(
    GetWeddingVendorsParams params,
  ) =>
      _repository.getVendors(
        page: params.page,
        perPage: params.perPage,
        category: params.category,
        query: params.query,
      );
}

class GetWeddingVendorsParams extends Equatable {
  const GetWeddingVendorsParams({
    this.page = 1,
    this.perPage = 20,
    this.category,
    this.query,
  });

  final int page;
  final int perPage;
  final String? category;
  final String? query;

  @override
  List<Object?> get props => [page, perPage, category, query];
}
