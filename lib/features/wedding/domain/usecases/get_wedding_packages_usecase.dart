import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/network/paginated_response.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_package_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class GetWeddingPackagesUseCase
    extends UseCase<PaginatedResponse<WeddingPackageEntity>, PaginationParams> {
  const GetWeddingPackagesUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<WeddingPackageEntity>>> call(
    PaginationParams params,
  ) =>
      _repository.getPackages(
        page: params.page,
        perPage: params.perPage,
      );
}
