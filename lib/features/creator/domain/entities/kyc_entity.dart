import 'package:equatable/equatable.dart';

enum KycDocumentType { aadhaarCard, panCard, passport, driversLicense, voterId }

extension KycDocumentTypeX on KycDocumentType {
  String get label => switch (this) {
        KycDocumentType.aadhaarCard => 'Aadhaar Card',
        KycDocumentType.panCard => 'PAN Card',
        KycDocumentType.passport => 'Passport',
        KycDocumentType.driversLicense => "Driver's Licence",
        KycDocumentType.voterId => 'Voter ID',
      };

  String get apiValue => switch (this) {
        KycDocumentType.aadhaarCard => 'aadhaar_card',
        KycDocumentType.panCard => 'pan_card',
        KycDocumentType.passport => 'passport',
        KycDocumentType.driversLicense => 'drivers_license',
        KycDocumentType.voterId => 'voter_id',
      };

  bool get requiresBackSide => this == KycDocumentType.aadhaarCard ||
      this == KycDocumentType.driversLicense ||
      this == KycDocumentType.voterId;

  static KycDocumentType? fromString(String? value) => switch (value) {
        'aadhaar_card' => KycDocumentType.aadhaarCard,
        'pan_card' => KycDocumentType.panCard,
        'passport' => KycDocumentType.passport,
        'drivers_license' => KycDocumentType.driversLicense,
        'voter_id' => KycDocumentType.voterId,
        _ => null,
      };
}

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
