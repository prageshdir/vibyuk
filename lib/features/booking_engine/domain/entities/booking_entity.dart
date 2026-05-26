import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  confirmed,
  active,
  inProgress,
  pendingDelivery,
  completed,
  cancelled,
  disputed,
  refunded,
}

class BookingEntity extends Equatable {
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

  const BookingEntity({
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

  bool get isPending => status == BookingStatus.pending;
  bool get isActive =>
      status == BookingStatus.active || status == BookingStatus.inProgress;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isDisputed => status == BookingStatus.disputed;

  double get milestoneProgress =>
      milestonesTotal == 0 ? 0 : milestonesCompleted / milestonesTotal;

  @override
  List<Object?> get props => [
        id, creatorId, creatorName, creatorAvatarUrl, businessId, businessName,
        businessLogoUrl, packageId, packageTitle, campaignId, campaignTitle,
        totalAmount, currency, status, cancelReason, scheduledDate,
        confirmedAt, completedAt, cancelledAt, milestonesTotal,
        milestonesCompleted, hasContract, contractSigned, hasActiveDispute,
        createdAt, updatedAt,
      ];
}
