import 'package:flutter/material.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static (String, Color) _config(BookingStatus s) => switch (s) {
        BookingStatus.pending => ('Pending', Colors.orange),
        BookingStatus.confirmed => ('Confirmed', Colors.blue),
        BookingStatus.active => ('Active', Colors.green),
        BookingStatus.inProgress => ('In Progress', Colors.teal),
        BookingStatus.pendingDelivery => ('Pending Delivery', Colors.purple),
        BookingStatus.completed => ('Completed', Colors.green),
        BookingStatus.cancelled => ('Cancelled', Colors.red),
        BookingStatus.disputed => ('Disputed', Colors.deepOrange),
        BookingStatus.refunded => ('Refunded', Colors.grey),
      };
}
