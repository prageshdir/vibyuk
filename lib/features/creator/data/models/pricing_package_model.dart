import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';

class PricingPackageModel {
  const PricingPackageModel({
    required this.id,
    required this.creatorId,
    required this.packageType,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.deliveryDays,
    this.inclusions = const [],
    required this.revisions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String creatorId;
  final String packageType;
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

  factory PricingPackageModel.fromJson(Map<String, dynamic> json) =>
      PricingPackageModel(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        packageType: json['package_type'] as String? ?? 'basic',
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'INR',
        deliveryDays: json['delivery_days'] as int,
        inclusions: (json['inclusions'] as List?)?.cast<String>() ?? [],
        revisions: json['revisions'] as int? ?? 1,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  PricingPackageEntity toEntity() => PricingPackageEntity(
        id: id,
        creatorId: creatorId,
        packageType: _parseType(packageType),
        title: title,
        description: description,
        price: price,
        currency: currency,
        deliveryDays: deliveryDays,
        inclusions: inclusions,
        revisions: revisions,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static PackageType _parseType(String v) => PackageType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => PackageType.basic,
      );
}
