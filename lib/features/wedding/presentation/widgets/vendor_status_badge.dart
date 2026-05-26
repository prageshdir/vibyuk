import 'package:flutter/material.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';

class VendorStatusBadge extends StatelessWidget {
  final VendorBookingStatus status;
  const VendorStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      VendorBookingStatus.pending => ('Pending', Colors.orange, Icons.pending_outlined),
      VendorBookingStatus.confirmed => ('Confirmed', Colors.green, Icons.check_circle_outline),
      VendorBookingStatus.cancelled => ('Cancelled', Colors.red, Icons.cancel_outlined),
      VendorBookingStatus.completed => ('Completed', Colors.blue, Icons.done_all),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
