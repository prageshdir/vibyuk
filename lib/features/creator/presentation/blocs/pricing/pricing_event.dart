part of 'pricing_bloc.dart';

sealed class PricingEvent extends Equatable {
  const PricingEvent();
}

class LoadPricingPackagesEvent extends PricingEvent {
  const LoadPricingPackagesEvent();
  @override
  List<Object?> get props => [];
}

class CreatePricingPackageEvent extends PricingEvent {
  const CreatePricingPackageEvent({
    required this.packageType,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.deliveryDays,
    required this.inclusions,
    required this.revisions,
  });
  final PackageType packageType;
  final String title;
  final String description;
  final double price;
  final String currency;
  final int deliveryDays;
  final List<String> inclusions;
  final int revisions;
  @override
  List<Object?> get props =>
      [packageType, title, description, price, currency, deliveryDays, inclusions, revisions];
}

class UpdatePricingPackageEvent extends PricingEvent {
  const UpdatePricingPackageEvent({
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
  final String packageId;
  final String title;
  final String description;
  final double price;
  final String currency;
  final int deliveryDays;
  final List<String> inclusions;
  final int revisions;
  final bool isActive;
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

class DeletePricingPackageEvent extends PricingEvent {
  const DeletePricingPackageEvent({required this.packageId});
  final String packageId;
  @override
  List<Object?> get props => [packageId];
}
