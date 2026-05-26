import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_reschedule_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/reschedule/reschedule_bloc.dart';

class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({
    super.key,
    required this.bookingId,
    required this.currentUserId,
    this.existingReschedule,
  });

  final String bookingId;
  final String currentUserId;
  final BookingRescheduleEntity? existingReschedule;

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  final _reasonCtrl = TextEditingController();
  final _declineReasonCtrl = TextEditingController();
  DateTime? _selectedDate;

  bool get _isRespondMode =>
      widget.existingReschedule != null &&
      widget.existingReschedule!.isPending &&
      widget.existingReschedule!.requestedByUserId != widget.currentUserId;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _declineReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRespondMode ? 'Reschedule Request' : 'Request Reschedule',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocConsumer<RescheduleBloc, RescheduleState>(
        listener: (context, state) {
          if (state is RescheduleSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isRespondMode
                    ? 'Response submitted'
                    : 'Reschedule requested'),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is RescheduleErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is RescheduleSubmittingState;
          return _isRespondMode
              ? _RespondView(
                  reschedule: widget.existingReschedule!,
                  declineReasonCtrl: _declineReasonCtrl,
                  isSubmitting: isSubmitting,
                  onAccept: () => context.read<RescheduleBloc>().add(
                        RespondToRescheduleSubmitEvent(
                          rescheduleId: widget.existingReschedule!.id,
                          accept: true,
                        ),
                      ),
                  onDecline: () {
                    if (_declineReasonCtrl.text.trim().isEmpty) return;
                    context.read<RescheduleBloc>().add(
                          RespondToRescheduleSubmitEvent(
                            rescheduleId: widget.existingReschedule!.id,
                            accept: false,
                            declineReason: _declineReasonCtrl.text.trim(),
                          ),
                        );
                  },
                )
              : _RequestForm(
                  bookingId: widget.bookingId,
                  selectedDate: _selectedDate,
                  reasonCtrl: _reasonCtrl,
                  isSubmitting: isSubmitting,
                  onPickDate: () => _pickDate(context),
                  onSubmit: () {
                    if (_selectedDate == null) return;
                    context.read<RescheduleBloc>().add(
                          RequestRescheduleSubmitEvent(
                            bookingId: widget.bookingId,
                            newDate: _selectedDate!,
                            reason: _reasonCtrl.text.trim().isEmpty
                                ? null
                                : _reasonCtrl.text.trim(),
                          ),
                        );
                  },
                );
        },
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}

class _RequestForm extends StatelessWidget {
  const _RequestForm({
    required this.bookingId,
    required this.selectedDate,
    required this.reasonCtrl,
    required this.isSubmitting,
    required this.onPickDate,
    required this.onSubmit,
  });

  final String bookingId;
  final DateTime? selectedDate;
  final TextEditingController reasonCtrl;
  final bool isSubmitting;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'A reschedule request will be sent to the other party for approval.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('New Date',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate == null
                        ? 'Select a date'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selectedDate == null
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('Reason (optional)',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: reasonCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Explain why you need to reschedule...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: isSubmitting || selectedDate == null ? null : onSubmit,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52)),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Send Reschedule Request'),
          ),
        ],
      ),
    );
  }
}

class _RespondView extends StatelessWidget {
  const _RespondView({
    required this.reschedule,
    required this.declineReasonCtrl,
    required this.isSubmitting,
    required this.onAccept,
    required this.onDecline,
  });

  final BookingRescheduleEntity reschedule;
  final TextEditingController declineReasonCtrl;
  final bool isSubmitting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request from ${reschedule.requestedByName}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _DateRow(
                  label: 'Current Date',
                  date: reschedule.originalDate,
                  icon: Icons.today_outlined,
                ),
                const SizedBox(height: 10),
                _DateRow(
                  label: 'Proposed Date',
                  date: reschedule.proposedDate,
                  icon: Icons.event_available_outlined,
                  highlight: true,
                ),
                if (reschedule.reason != null) ...[
                  const SizedBox(height: 16),
                  Text('Reason',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(reschedule.reason!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(height: 1.5)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Decline Reason (if rejecting)',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: declineReasonCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Provide a reason for declining...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isSubmitting ? null : onAccept,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.date,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final DateTime date;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: highlight
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: highlight ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
