import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class GetVendorDetailUseCase
    extends UseCase<WeddingVendorEntity, VendorIdParams> {
  const GetVendorDetailUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingVendorEntity>> call(VendorIdParams params) =>
      _repository.getVendorDetail(params.vendorId);
}

class VendorIdParams extends Equatable {
  const VendorIdParams(this.vendorId);
  final String vendorId;

  @override
  List<Object?> get props => [vendorId];
}
