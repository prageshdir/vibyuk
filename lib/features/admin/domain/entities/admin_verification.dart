import 'package:equatable/equatable.dart';

enum VerificationStatus { pending, underReview, approved, rejected, moreInfoRequired }
enum VerificationType { identity, creator, business, bankAccount }

class VerificationDocument extends Equatable {
  final String id;
  final String type;
  final String url;
  final String? expiryDate;
  final bool isValid;

  const VerificationDocument({
    required this.id,
    required this.type,
    required this.url,
    this.expiryDate,
    required this.isValid,
  });

  @override
  List<Object?> get props => [id, type, url, expiryDate, isValid];
}

class AdminVerification extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;
  final VerificationType type;
  final VerificationStatus status;
  final List<VerificationDocument> documents;
  final String? submittedBusinessName;
  final String? submittedWebsite;
  final String? reviewedByModeratorId;
  final String? reviewedByModeratorName;
  final String? reviewNote;
  final String? rejectionReason;
  final int attemptCount;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const AdminVerification({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
    required this.type,
    required this.status,
    required this.documents,
    this.submittedBusinessName,
    this.submittedWebsite,
    this.reviewedByModeratorId,
    this.reviewedByModeratorName,
    this.reviewNote,
    this.rejectionReason,
    required this.attemptCount,
    required this.submittedAt,
    this.reviewedAt,
  });

  bool get isPending => status == VerificationStatus.pending;
  bool get isUnderReview => status == VerificationStatus.underReview;
  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;
  bool get needsMoreInfo => status == VerificationStatus.moreInfoRequired;
  int get daysPending => DateTime.now().difference(submittedAt).inDays;

  AdminVerification copyWith({
    VerificationStatus? status,
    String? reviewedByModeratorId,
    String? reviewedByModeratorName,
    String? reviewNote,
    String? rejectionReason,
    DateTime? reviewedAt,
  }) {
    return AdminVerification(
      id: id, userId: userId, userName: userName, userEmail: userEmail,
      userAvatarUrl: userAvatarUrl, type: type,
      status: status ?? this.status, documents: documents,
      submittedBusinessName: submittedBusinessName,
      submittedWebsite: submittedWebsite,
      reviewedByModeratorId: reviewedByModeratorId ?? this.reviewedByModeratorId,
      reviewedByModeratorName: reviewedByModeratorName ?? this.reviewedByModeratorName,
      reviewNote: reviewNote ?? this.reviewNote,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      attemptCount: attemptCount, submittedAt: submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, userName, userEmail, userAvatarUrl, type, status,
        documents, submittedBusinessName, submittedWebsite,
        reviewedByModeratorId, reviewedByModeratorName, reviewNote,
        rejectionReason, attemptCount, submittedAt, reviewedAt,
      ];
}
