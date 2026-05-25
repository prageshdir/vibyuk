import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_package_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class BuildCustomPackageUseCase
    extends UseCase<WeddingPackageEntity, BuildPackageParams> {
  const BuildCustomPackageUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingPackageEntity>> call(
    BuildPackageParams params,
  ) =>
      _repository.buildCustomPackage(
        params.weddingId,
        {
          'vendor_ids': params.vendorIds,
          if (params.customName != null) 'name': params.customName,
        },
      );
}

class BuildPackageParams extends Equatable {
  const BuildPackageParams({
    required this.weddingId,
    required this.vendorIds,
    this.customName,
  });

  final String weddingId;
  final List<String> vendorIds;
  final String? customName;

  @override
  List<Object?> get props => [weddingId, vendorIds, customName];
}
