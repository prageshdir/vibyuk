import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';

class BookingRequestModel {
  const BookingRequestModel({
    required this.id,
    required this.creatorId,
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
    required this.campaignId,
    required this.campaignTitle,
    required this.packageId,
    required this.packageTitle,
    required this.offeredPrice,
    required this.currency,
    required this.requestedDeliveryDate,
    this.message,
    required this.status,
    this.counterOfferPrice,
    this.counterOfferMessage,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String creatorId;
  final String businessId;
  final String businessName;
  final String? businessLogoUrl;
  final String campaignId;
  final String campaignTitle;
  final String packageId;
  final String packageTitle;
  final double offeredPrice;
  final String currency;
  final String requestedDeliveryDate;
  final String? message;
  final String status;
  final double? counterOfferPrice;
  final String? counterOfferMessage;
  final String createdAt;
  final String expiresAt;

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) =>
      BookingRequestModel(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        businessId: json['business_id'] as String,
        businessName: json['business_name'] as String,
        businessLogoUrl: json['business_logo_url'] as String?,
        campaignId: json['campaign_id'] as String,
        campaignTitle: json['campaign_title'] as String,
        packageId: json['package_id'] as String,
        packageTitle: json['package_title'] as String,
        offeredPrice: (json['offered_price'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'GBP',
        requestedDeliveryDate: json['requested_delivery_date'] as String,
        message: json['message'] as String?,
        status: json['status'] as String? ?? 'pending',
        counterOfferPrice: (json['counter_offer_price'] as num?)?.toDouble(),
        counterOfferMessage: json['counter_offer_message'] as String?,
        createdAt: json['created_at'] as String,
        expiresAt: json['expires_at'] as String,
      );

  BookingRequestEntity toEntity() => BookingRequestEntity(
        id: id,
        creatorId: creatorId,
        businessId: businessId,
        businessName: businessName,
        businessLogoUrl: businessLogoUrl,
        campaignId: campaignId,
        campaignTitle: campaignTitle,
        packageId: packageId,
        packageTitle: packageTitle,
        offeredPrice: offeredPrice,
        currency: currency,
        requestedDeliveryDate: DateTime.parse(requestedDeliveryDate),
        message: message,
        status: BookingRequestStatus.values.firstWhere(
          (e) => e.name == status,
          orElse: () => BookingRequestStatus.pending,
        ),
        counterOfferPrice: counterOfferPrice,
        counterOfferMessage: counterOfferMessage,
        createdAt: DateTime.parse(createdAt),
        expiresAt: DateTime.parse(expiresAt),
      );
}
