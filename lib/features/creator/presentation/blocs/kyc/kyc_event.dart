part of 'kyc_bloc.dart';

sealed class KycEvent extends Equatable {
  const KycEvent();
}

class LoadKycStatusEvent extends KycEvent {
  const LoadKycStatusEvent();
  @override
  List<Object?> get props => [];
}

class SubmitKycEvent extends KycEvent {
  const SubmitKycEvent({
    required this.documentType,
    required this.documentFrontPath,
    this.documentBackPath,
    required this.selfiePath,
  });
  final KycDocumentType documentType;
  final String documentFrontPath;
  final String? documentBackPath;
  final String selfiePath;
  @override
  List<Object?> get props =>
      [documentType, documentFrontPath, documentBackPath, selfiePath];
}
