import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';

enum VendorBookingStatus { pending, confirmed, cancelled, completed }

class WeddingBookingEntity extends Equatable {
  const WeddingBookingEntity({
    required this.id,
    required this.weddingId,
    required this.vendorId,
    required this.status,
    required this.agreedPrice,
    required this.depositPaid,
    required this.eventDate,
    required this.createdAt,
    this.vendor,
    this.depositAmount,
    this.notes,
  });

  final String id;
  final String weddingId;
  final String vendorId;
  final WeddingVendorEntity? vendor;
  final VendorBookingStatus status;
  final double agreedPrice;
  final double? depositAmount;
  final bool depositPaid;
  final DateTime eventDate;
  final String? notes;
  final DateTime createdAt;

  double get remainingBalance =>
      agreedPrice - (depositPaid ? (depositAmount ?? 0) : 0);

  bool get isActive =>
      status == VendorBookingStatus.pending ||
      status == VendorBookingStatus.confirmed;

  @override
  List<Object?> get props => [
        id,
        weddingId,
        vendorId,
        vendor,
        status,
        agreedPrice,
        depositAmount,
        depositPaid,
        eventDate,
        notes,
        createdAt,
      ];
}
