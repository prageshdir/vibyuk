import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';

part 'wedding_booking_dto.freezed.dart';
part 'wedding_booking_dto.g.dart';

@freezed
class WeddingBookingDto with _$WeddingBookingDto {
  const factory WeddingBookingDto({
    required String id,
    @JsonKey(name: 'wedding_id') required String weddingId,
    @JsonKey(name: 'vendor_id') required String vendorId,
    @Default('pending') String status,
    @JsonKey(name: 'agreed_price') required double agreedPrice,
    @JsonKey(name: 'deposit_amount') double? depositAmount,
    @JsonKey(name: 'deposit_paid') @Default(false) bool depositPaid,
    @JsonKey(name: 'event_date') required String eventDate,
    String? notes,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _WeddingBookingDto;

  factory WeddingBookingDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingBookingDtoFromJson(json);

  factory WeddingBookingDto.fromEntity(WeddingBookingEntity e) =>
      WeddingBookingDto(
        id: e.id,
        weddingId: e.weddingId,
        vendorId: e.vendorId,
        status: e.status.name,
        agreedPrice: e.agreedPrice,
        depositAmount: e.depositAmount,
        depositPaid: e.depositPaid,
        eventDate: e.eventDate.toIso8601String(),
        notes: e.notes,
        createdAt: e.createdAt.toIso8601String(),
      );
}

extension WeddingBookingDtoX on WeddingBookingDto {
  WeddingBookingEntity toEntity() => WeddingBookingEntity(
        id: id,
        weddingId: weddingId,
        vendorId: vendorId,
        status: _parseStatus(status),
        agreedPrice: agreedPrice,
        depositAmount: depositAmount,
        depositPaid: depositPaid,
        eventDate: DateTime.parse(eventDate),
        notes: notes,
        createdAt: DateTime.parse(createdAt),
      );

  VendorBookingStatus _parseStatus(String s) => switch (s) {
        'confirmed' => VendorBookingStatus.confirmed,
        'cancelled' => VendorBookingStatus.cancelled,
        'completed' => VendorBookingStatus.completed,
        _ => VendorBookingStatus.pending,
      };
}
