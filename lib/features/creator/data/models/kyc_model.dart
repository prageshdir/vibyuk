import 'package:vibyuk/features/creator/domain/entities/kyc_entity.dart';

class KycModel {
  const KycModel({
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

  final String creatorId;
  final String status;
  final String? documentType;
  final String? documentFrontUrl;
  final String? documentBackUrl;
  final String? selfieUrl;
  final String? rejectionReason;
  final String? submittedAt;
  final String? reviewedAt;

  factory KycModel.fromJson(Map<String, dynamic> json) => KycModel(
        creatorId: json['creator_id'] as String,
        status: json['status'] as String? ?? 'notSubmitted',
        documentType: json['document_type'] as String?,
        documentFrontUrl: json['document_front_url'] as String?,
        documentBackUrl: json['document_back_url'] as String?,
        selfieUrl: json['selfie_url'] as String?,
        rejectionReason: json['rejection_reason'] as String?,
        submittedAt: json['submitted_at'] as String?,
        reviewedAt: json['reviewed_at'] as String?,
      );

  KycEntity toEntity() => KycEntity(
        creatorId: creatorId,
        status: KycVerificationStatus.values.firstWhere(
          (e) => e.name == status,
          orElse: () => KycVerificationStatus.notSubmitted,
        ),
        documentType: KycDocumentTypeX.fromString(documentType),
        documentFrontUrl: documentFrontUrl,
        documentBackUrl: documentBackUrl,
        selfieUrl: selfieUrl,
        rejectionReason: rejectionReason,
        submittedAt: submittedAt != null ? DateTime.parse(submittedAt!) : null,
        reviewedAt: reviewedAt != null ? DateTime.parse(reviewedAt!) : null,
      );
}
