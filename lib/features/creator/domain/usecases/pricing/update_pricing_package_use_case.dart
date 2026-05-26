import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class UpdatePricingPackageUseCase
    extends UseCase<PricingPackageEntity, UpdatePricingPackageParams> {
  final CreatorRepository _repository;
  const UpdatePricingPackageUseCase(this._repository);

  @override
  Future<Either<Failure, PricingPackageEntity>> call(
          UpdatePricingPackageParams params) =>
      _repository.updatePricingPackage(
        packageId: params.packageId,
        title: params.title,
        description: params.description,
        price: params.price,
        currency: params.currency,
        deliveryDays: params.deliveryDays,
        inclusions: params.inclusions,
        revisions: params.revisions,
        isActive: params.isActive,
      );
}

class UpdatePricingPackageParams extends Equatable {
  final String packageId;
  final String title;
  final String description;
  final double price;
  final String currency;
  final int deliveryDays;
  final List<String> inclusions;
  final int revisions;
  final bool isActive;

  const UpdatePricingPackageParams({
    required this.packageId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.deliveryDays,
    required this.inclusions,
    required this.revisions,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        packageId,
        title,
        description,
        price,
        currency,
        deliveryDays,
        inclusions,
        revisions,
        isActive,
      ];
}
