import 'package:equatable/equatable.dart';

enum KycDocumentType { passport, driversLicense, nationalId }

enum KycVerificationStatus { notSubmitted, pendingReview, approved, rejected }

class KycEntity extends Equatable {
  final String creatorId;
  final KycVerificationStatus status;
  final KycDocumentType? documentType;
  final String? documentFrontUrl;
  final String? documentBackUrl;
  final String? selfieUrl;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  const KycEntity({
    required this.creatorId,
    required this.status,
    this.documentType,
    this.documentFrontUrl,
    this.documentBackUrl,
    this.selfieUrl,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  bool get isSubmitted => status != KycVerificationStatus.notSubmitted;
  bool get isApproved => status == KycVerificationStatus.approved;
  bool get needsResubmission => status == KycVerificationStatus.rejected;

  @override
  List<Object?> get props => [
        creatorId,
        status,
        documentType,
        documentFrontUrl,
        documentBackUrl,
        selfieUrl,
        rejectionReason,
        submittedAt,
        reviewedAt,
      ];
}
