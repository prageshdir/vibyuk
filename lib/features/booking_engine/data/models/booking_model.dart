import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatarUrl,
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
    required this.packageId,
    required this.packageTitle,
    this.campaignId,
    this.campaignTitle,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.cancelReason,
    required this.scheduledDate,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    required this.milestonesTotal,
    required this.milestonesCompleted,
    required this.hasContract,
    required this.contractSigned,
    required this.hasActiveDispute,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String creatorId;
  final String creatorName;
  final String? creatorAvatarUrl;
  final String businessId;
  final String businessName;
  final String? businessLogoUrl;
  final String packageId;
  final String packageTitle;
  final String? campaignId;
  final String? campaignTitle;
  final double totalAmount;
  final String currency;
  final BookingStatus status;
  final String? cancelReason;
  final DateTime scheduledDate;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final int milestonesTotal;
  final int milestonesCompleted;
  final bool hasContract;
  final bool contractSigned;
  final bool hasActiveDispute;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BookingModel.fromJson(Map<String, dynamic> j) => BookingModel(
        id: j['id'] as String,
        creatorId: j['creator_id'] as String,
        creatorName: j['creator_name'] as String,
        creatorAvatarUrl: j['creator_avatar_url'] as String?,
        businessId: j['business_id'] as String,
        businessName: j['business_name'] as String,
        businessLogoUrl: j['business_logo_url'] as String?,
        packageId: j['package_id'] as String,
        packageTitle: j['package_title'] as String,
        campaignId: j['campaign_id'] as String?,
        campaignTitle: j['campaign_title'] as String?,
        totalAmount: (j['total_amount'] as num).toDouble(),
        currency: j['currency'] as String,
        status: BookingStatus.values.firstWhere(
            (s) => s.name == j['status'],
            orElse: () => BookingStatus.pending),
        cancelReason: j['cancel_reason'] as String?,
        scheduledDate: DateTime.parse(j['scheduled_date'] as String),
        confirmedAt: j['confirmed_at'] != null
            ? DateTime.parse(j['confirmed_at'] as String)
            : null,
        completedAt: j['completed_at'] != null
            ? DateTime.parse(j['completed_at'] as String)
            : null,
        cancelledAt: j['cancelled_at'] != null
            ? DateTime.parse(j['cancelled_at'] as String)
            : null,
        milestonesTotal: j['milestones_total'] as int? ?? 0,
        milestonesCompleted: j['milestones_completed'] as int? ?? 0,
        hasContract: j['has_contract'] as bool? ?? false,
        contractSigned: j['contract_signed'] as bool? ?? false,
        hasActiveDispute: j['has_active_dispute'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );

  BookingEntity toEntity() => BookingEntity(
        id: id,
        creatorId: creatorId,
        creatorName: creatorName,
        creatorAvatarUrl: creatorAvatarUrl,
        businessId: businessId,
        businessName: businessName,
        businessLogoUrl: businessLogoUrl,
        packageId: packageId,
        packageTitle: packageTitle,
        campaignId: campaignId,
        campaignTitle: campaignTitle,
        totalAmount: totalAmount,
        currency: currency,
        status: status,
        cancelReason: cancelReason,
        scheduledDate: scheduledDate,
        confirmedAt: confirmedAt,
        completedAt: completedAt,
        cancelledAt: cancelledAt,
        milestonesTotal: milestonesTotal,
        milestonesCompleted: milestonesCompleted,
        hasContract: hasContract,
        contractSigned: contractSigned,
        hasActiveDispute: hasActiveDispute,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
