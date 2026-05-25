part of 'admin_verification_bloc.dart';

sealed class AdminVerificationEvent {}

final class AdminVerificationFetch extends AdminVerificationEvent {
  final bool refresh;
  AdminVerificationFetch({this.refresh = false});
}

final class AdminVerificationLoadMore extends AdminVerificationEvent {}

final class AdminVerificationStatusFilterChanged
    extends AdminVerificationEvent {
  final VerificationStatus? status;
  AdminVerificationStatusFilterChanged(this.status);
}

final class AdminVerificationTypeFilterChanged extends AdminVerificationEvent {
  final VerificationType? type;
  AdminVerificationTypeFilterChanged(this.type);
}

final class AdminVerificationSelect extends AdminVerificationEvent {
  final String verificationId;
  AdminVerificationSelect(this.verificationId);
}

final class AdminVerificationReview extends AdminVerificationEvent {
  final String verificationId;
  final VerificationStatus decision;
  final String? note;
  final String? rejectionReason;

  AdminVerificationReview({
    required this.verificationId,
    required this.decision,
    this.note,
    this.rejectionReason,
  });
}
