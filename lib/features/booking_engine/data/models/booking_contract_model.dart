import 'package:vibyuk/features/booking_engine/domain/entities/booking_contract_entity.dart';

class BookingContractModel {
  const BookingContractModel({
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

  factory BookingContractModel.fromJson(Map<String, dynamic> j) =>
      BookingContractModel(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String,
        status: ContractStatus.values.firstWhere(
            (s) => s.name == j['status'],
            orElse: () => ContractStatus.draft),
        contractText: j['contract_text'] as String? ?? '',
        creatorSignatureUrl: j['creator_signature_url'] as String?,
        businessSignatureUrl: j['business_signature_url'] as String?,
        creatorSignedAt: j['creator_signed_at'] != null
            ? DateTime.parse(j['creator_signed_at'] as String)
            : null,
        businessSignedAt: j['business_signed_at'] != null
            ? DateTime.parse(j['business_signed_at'] as String)
            : null,
        executedAt: j['executed_at'] != null
            ? DateTime.parse(j['executed_at'] as String)
            : null,
        downloadUrl: j['download_url'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  BookingContractEntity toEntity() => BookingContractEntity(
        id: id,
        bookingId: bookingId,
        status: status,
        contractText: contractText,
        creatorSignatureUrl: creatorSignatureUrl,
        businessSignatureUrl: businessSignatureUrl,
        creatorSignedAt: creatorSignedAt,
        businessSignedAt: businessSignedAt,
        executedAt: executedAt,
        downloadUrl: downloadUrl,
        createdAt: createdAt,
      );
}
