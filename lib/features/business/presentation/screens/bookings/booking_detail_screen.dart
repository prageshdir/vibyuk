import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/booking/booking_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<BookingBloc>()
        .add(LoadBookingDetailEvent(bookingId: widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCancelledState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled')),
          );
          context.pop();
        }
        if (state is BookingStatusUpdatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Booking ${state.booking.status.label.toLowerCase()}'),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BookingLoadingState) {
          return const Scaffold(body: Center(child: AppLoader()));
        }

        BookingEntity? booking;
        if (state is BookingDetailLoadedState) {
          booking = state.booking;
        } else if (state is BookingStatusUpdatedState) {
          booking = state.booking;
        }

        if (booking == null) {
          return Scaffold(
            appBar: AppBar(),
            body: BusinessEmptyState(
              title: 'Booking not found',
              icon: Icons.calendar_today_rounded,
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            ),
          );
        }

        return _BookingDetailView(booking: booking);
      },
    );
  }
}

class _BookingDetailView extends StatelessWidget {
  final BookingEntity booking;
  const _BookingDetailView({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final creator = booking.creator;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusCard(booking: booking),
            const SizedBox(height: 20),
            if (creator != null) ...[
              Text(
                'Creator',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _CreatorInfo(creator: creator),
              const SizedBox(height: 20),
            ],
            Text(
              'Booking details',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Scheduled',
              value: DateFormat('EEE, d MMMM y · h:mm a')
                  .format(booking.scheduledAt),
              icon: Icons.access_time_rounded,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Amount',
              value: booking.priceDisplay,
              icon: Icons.payments_rounded,
            ),
            if (booking.campaignId != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Campaign',
                value: booking.campaignId!,
                icon: Icons.campaign_rounded,
              ),
            ],
            if (booking.notes != null) ...[
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                booking.notes!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (booking.cancellationReason != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_rounded,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.cancellationReason!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: !booking.status.isTerminal
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: OutlinedButton(
                  onPressed: () => _confirmCancel(context, booking),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Cancel Booking'),
                ),
              ),
            )
          : null,
    );
  }

  void _confirmCancel(BuildContext context, BookingEntity booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingBloc>().add(
                    CancelBookingEvent(bookingId: booking.id),
                  );
            },
            style: TextButton.styleFrom(
                foregroundColor: AppColors.error),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final BookingEntity booking;
  const _StatusCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (booking.status) {
      BookingStatus.pending =>
        (AppColors.warningContainer, AppColors.warning),
      BookingStatus.confirmed =>
        (AppColors.primaryContainer, AppColors.primary),
      BookingStatus.inProgress =>
        (AppColors.tertiaryContainer, AppColors.onTertiaryContainer),
      BookingStatus.completed =>
        (AppColors.successContainer, AppColors.success),
      BookingStatus.cancelled =>
        (AppColors.errorContainer, AppColors.error),
      BookingStatus.disputed =>
        (AppColors.errorContainer, AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(color: fg.withOpacity(0.7), fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  booking.status.label,
                  style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          Text(
            booking.priceDisplay,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w800, fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _CreatorInfo extends StatelessWidget {
  final creator;
  const _CreatorInfo({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryContainer,
          backgroundImage: creator.avatarUrl != null
              ? NetworkImage(creator.avatarUrl!)
              : null,
          child: creator.avatarUrl == null
              ? Text(
                  creator.initials,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                creator.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (creator.categories.isNotEmpty)
                Text(
                  creator.categories.first,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
