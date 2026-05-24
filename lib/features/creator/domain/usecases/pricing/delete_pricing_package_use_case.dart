import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class DeletePricingPackageUseCase
    extends UseCase<void, DeletePricingPackageParams> {
  final CreatorRepository _repository;
  const DeletePricingPackageUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeletePricingPackageParams params) =>
      _repository.deletePricingPackage(packageId: params.packageId);
}

class DeletePricingPackageParams extends Equatable {
  final String packageId;
  const DeletePricingPackageParams({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}
