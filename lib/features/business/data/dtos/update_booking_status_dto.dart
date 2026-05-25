import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';

class UpdateBookingStatusDto {
  const UpdateBookingStatusDto({required this.status, this.reason});

  final String status;
  final String? reason;

  factory UpdateBookingStatusDto.fromStatus(BookingStatus status,
          {String? reason}) =>
      UpdateBookingStatusDto(status: status.name, reason: reason);

  Map<String, dynamic> toJson() => {
        'status': status,
        if (reason != null) 'reason': reason,
      };
}
