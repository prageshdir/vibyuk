import 'package:equatable/equatable.dart';

enum BookingRequestStatus {
  pending,
  accepted,
  declined,
  counterOffered,
  expired,
  cancelled,
}

class BookingRequestEntity extends Equatable {
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
  final DateTime requestedDeliveryDate;
  final String? message;
  final BookingRequestStatus status;
  final double? counterOfferPrice;
  final String? counterOfferMessage;
  final DateTime createdAt;
  final DateTime expiresAt;

  const BookingRequestEntity({
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

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == BookingRequestStatus.pending;
  bool get canRespond => isPending && !isExpired;

  @override
  List<Object?> get props => [
        id,
        creatorId,
        businessId,
        businessName,
        businessLogoUrl,
        campaignId,
        campaignTitle,
        packageId,
        packageTitle,
        offeredPrice,
        currency,
        requestedDeliveryDate,
        message,
        status,
        counterOfferPrice,
        counterOfferMessage,
        createdAt,
        expiresAt,
      ];
}
