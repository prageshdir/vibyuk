import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/booking_detail/booking_detail_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/widgets/booking_status_chip.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context
        .read<BookingDetailBloc>()
        .add(LoadBookingDetailEvent(bookingId: widget.bookingId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingDetailBloc, BookingDetailState>(
      listener: (context, state) {
        if (state is BookingDetailLoadedState) {
          if (state.actionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action completed successfully')),
            );
          } else if (state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionError!.message)),
            );
          }
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            state is BookingDetailLoadedState
                ? state.booking.businessName
                : 'Booking',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            if (state is BookingDetailLoadedState)
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                onPressed: () => context
                    .push(RouteNames.bookingEngineInvoice(widget.bookingId)),
                tooltip: 'Invoice',
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Milestones'),
              Tab(text: 'Timeline'),
              Tab(text: 'Contract'),
            ],
          ),
        ),
        body: switch (state) {
          BookingDetailLoadingState() =>
            const Center(child: AppLoader()),
          BookingDetailLoadedState(:final booking, :final isActioning) =>
            TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                    booking: booking, isActioning: isActioning),
                _PlaceholderTab(
                    icon: Icons.task_alt_rounded,
                    title: 'Milestones',
                    onTap: () => context.push(
                        RouteNames.bookingEngineMilestones(widget.bookingId))),
                _PlaceholderTab(
                    icon: Icons.timeline_rounded,
                    title: 'Timeline',
                    onTap: () => context.push(
                        RouteNames.bookingEngineTimeline(widget.bookingId))),
                _PlaceholderTab(
                    icon: Icons.description_outlined,
                    title: 'Contract',
                    onTap: () => context.push(
                        RouteNames.bookingEngineContract(widget.bookingId))),
              ],
            ),
          BookingDetailErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<BookingDetailBloc>().add(
                          LoadBookingDetailEvent(
                              bookingId: widget.bookingId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab(
      {required this.booking, required this.isActioning});
  final BookingEntity booking;
  final bool isActioning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + amount banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.7)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${booking.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    BookingStatusChip(status: booking.status),
                  ],
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: booking.businessLogoUrl != null
                      ? NetworkImage(booking.businessLogoUrl!)
                      : null,
                  child: booking.businessLogoUrl == null
                      ? Text(booking.businessName[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800))
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _InfoRow(label: 'Business', value: booking.businessName),
          _InfoRow(label: 'Package', value: booking.packageTitle),
          if (booking.campaignTitle != null)
            _InfoRow(label: 'Campaign', value: booking.campaignTitle!),
          _InfoRow(
              label: 'Scheduled Date',
              value: _formatDate(booking.scheduledDate)),
          if (booking.confirmedAt != null)
            _InfoRow(
                label: 'Confirmed',
                value: _formatDate(booking.confirmedAt!)),
          const Divider(height: 32),

          // Milestone progress
          if (booking.milestonesTotal > 0) ...[
            Text('Milestone Progress',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: booking.milestoneProgress,
                      minHeight: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${booking.milestonesCompleted}/${booking.milestonesTotal}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Quick actions
          if (booking.isPending) ...[
            FilledButton(
              onPressed: isActioning
                  ? null
                  : () => context.read<BookingDetailBloc>().add(
                        ConfirmBookingDetailEvent(
                            bookingId: booking.id),
                      ),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: isActioning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm Booking'),
            ),
            const SizedBox(height: 12),
          ],

          // Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.chat_outlined, size: 16),
                label: const Text('Negotiate'),
                onPressed: () => context.push(
                    RouteNames.bookingEngineNegotiation(booking.id)),
              ),
              if (booking.isActive)
                OutlinedButton.icon(
                  icon: const Icon(Icons.event_repeat_rounded, size: 16),
                  label: const Text('Reschedule'),
                  onPressed: () => context.push(
                      RouteNames.bookingEngineReschedule(booking.id)),
                ),
              if (booking.isActive && !booking.hasActiveDispute)
                OutlinedButton.icon(
                  icon: const Icon(Icons.warning_amber_rounded, size: 16),
                  label: const Text('Open Dispute'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepOrange),
                  onPressed: () => context.push(
                      RouteNames.bookingEngineDispute(booking.id)),
                ),
              if (!booking.isCancelled && !booking.isCompleted)
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error),
                  onPressed: () => _confirmCancel(context, booking),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, BookingEntity booking) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for cancellation.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                  hintText: 'Cancellation reason...'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back')),
          FilledButton(
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              context.read<BookingDetailBloc>().add(
                    CancelBookingDetailEvent(
                      bookingId: booking.id,
                      reason: reasonCtrl.text.trim(),
                    ),
                  );
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab(
      {required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onTap,
            child: Text('Open $title'),
          ),
        ],
      ),
    );
  }
}
