import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/widgets/booking_status_chip.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.booking,
  });

  final BookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.green.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 56, color: Colors.green),
              ),
              const SizedBox(height: 24),

              Text(
                'Booking Confirmed!',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your booking with ${booking.businessName} has been successfully placed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Booking summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primary.withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.primary.withOpacity(0.2),
                          backgroundImage: booking.businessLogoUrl != null
                              ? NetworkImage(booking.businessLogoUrl!)
                              : null,
                          child: booking.businessLogoUrl == null
                              ? Text(
                                  booking.businessName[0].toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(booking.businessName,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              Text(booking.packageTitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme
                                          .onSurfaceVariant)),
                            ],
                          ),
                        ),
                        BookingStatusChip(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Scheduled Date',
                      value:
                          '${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year}',
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.payments_outlined,
                      label: 'Total Amount',
                      value:
                          '${booking.currency} ${booking.totalAmount.toStringAsFixed(2)}',
                      valueBold: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Actions
              FilledButton(
                onPressed: () =>
                    context.go(RouteNames.bookingEngineDetail(booking.id)),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                child: const Text('View Booking'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(RouteNames.bookingEngineList),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('View All Bookings'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight:
                    valueBold ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }
}
