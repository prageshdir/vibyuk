import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class CreatePricingPackageUseCase
    extends UseCase<PricingPackageEntity, PricingPackageParams> {
  final CreatorRepository _repository;
  const CreatePricingPackageUseCase(this._repository);

  @override
  Future<Either<Failure, PricingPackageEntity>> call(
          PricingPackageParams params) =>
      _repository.createPricingPackage(
        packageType: params.packageType,
        title: params.title,
        description: params.description,
        price: params.price,
        currency: params.currency,
        deliveryDays: params.deliveryDays,
        inclusions: params.inclusions,
        revisions: params.revisions,
      );
}

class PricingPackageParams extends Equatable {
  final PackageType packageType;
  final String title;
  final String description;
  final double price;
  final String currency;
  final int deliveryDays;
  final List<String> inclusions;
  final int revisions;

  const PricingPackageParams({
    required this.packageType,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.deliveryDays,
    required this.inclusions,
    required this.revisions,
  });

  @override
  List<Object?> get props => [
        packageType,
        title,
        description,
        price,
        currency,
        deliveryDays,
        inclusions,
        revisions,
      ];
}
