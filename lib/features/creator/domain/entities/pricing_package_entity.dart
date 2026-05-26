import 'package:equatable/equatable.dart';

enum PackageType { basic, standard, premium }

class PricingPackageEntity extends Equatable {
  final String id;
  final String creatorId;
  final PackageType packageType;
  final String title;
  final String description;
  final double price;
  final String currency;
  final int deliveryDays;
  final List<String> inclusions;
  final int revisions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PricingPackageEntity({
    required this.id,
    required this.creatorId,
    required this.packageType,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.deliveryDays,
    required this.inclusions,
    required this.revisions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        creatorId,
        packageType,
        title,
        description,
        price,
        currency,
        deliveryDays,
        inclusions,
        revisions,
        isActive,
        createdAt,
        updatedAt,
      ];
}
