part of 'admin_verification_bloc.dart';

enum AdminVerificationStatus { initial, loading, loaded, loadingMore, error }

final class AdminVerificationState extends Equatable {
  final AdminVerificationStatus status;
  final List<AdminVerification> verifications;
  final AdminVerification? selectedVerification;
  final VerificationStatus? statusFilter;
  final VerificationType? typeFilter;
  final int currentPage;
  final bool hasMore;
  final bool isReviewing;
  final String? errorMessage;
  final String? reviewSuccess;

  const AdminVerificationState({
    this.status = AdminVerificationStatus.initial,
    this.verifications = const [],
    this.selectedVerification,
    this.statusFilter,
    this.typeFilter,
    this.currentPage = 0,
    this.hasMore = true,
    this.isReviewing = false,
    this.errorMessage,
    this.reviewSuccess,
  });

  AdminVerificationState copyWith({
    AdminVerificationStatus? status,
    List<AdminVerification>? verifications,
    AdminVerification? selectedVerification,
    VerificationStatus? Function()? statusFilter,
    VerificationType? Function()? typeFilter,
    int? currentPage,
    bool? hasMore,
    bool? isReviewing,
    String? errorMessage,
    String? reviewSuccess,
  }) {
    return AdminVerificationState(
      status: status ?? this.status,
      verifications: verifications ?? this.verifications,
      selectedVerification: selectedVerification ?? this.selectedVerification,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      typeFilter: typeFilter != null ? typeFilter() : this.typeFilter,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isReviewing: isReviewing ?? this.isReviewing,
      errorMessage: errorMessage,
      reviewSuccess: reviewSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status, verifications, selectedVerification, statusFilter, typeFilter,
        currentPage, hasMore, isReviewing, errorMessage, reviewSuccess,
      ];
}
