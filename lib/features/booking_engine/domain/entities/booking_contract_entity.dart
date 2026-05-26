import 'package:equatable/equatable.dart';

enum ContractStatus {
  draft,
  sentForSigning,
  signedByCreator,
  signedByBusiness,
  fullyExecuted,
  voided,
}

class BookingContractEntity extends Equatable {
  final String id;
  final String bookingId;
  final ContractStatus status;
  final String contractText;
  final String? creatorSignatureUrl;
  final String? businessSignatureUrl;
  final DateTime? creatorSignedAt;
  final DateTime? businessSignedAt;
  final DateTime? executedAt;
  final String? downloadUrl;
  final DateTime createdAt;

  const BookingContractEntity({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.contractText,
    this.creatorSignatureUrl,
    this.businessSignatureUrl,
    this.creatorSignedAt,
    this.businessSignedAt,
    this.executedAt,
    this.downloadUrl,
    required this.createdAt,
  });

  bool get isFullyExecuted => status == ContractStatus.fullyExecuted;
  bool get needsCreatorSignature =>
      status == ContractStatus.sentForSigning ||
      status == ContractStatus.signedByBusiness;
  bool get needsBusinessSignature =>
      status == ContractStatus.sentForSigning ||
      status == ContractStatus.signedByCreator;

  @override
  List<Object?> get props => [
        id, bookingId, status, contractText, creatorSignatureUrl,
        businessSignatureUrl, creatorSignedAt, businessSignedAt, executedAt,
        downloadUrl, createdAt,
      ];
}
