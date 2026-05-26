import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_dispute_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/dispute/dispute_bloc.dart';

class DisputeScreen extends StatefulWidget {
  const DisputeScreen({
    super.key,
    required this.bookingId,
    required this.currentUserId,
  });

  final String bookingId;
  final String currentUserId;

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  DisputeReason _selectedReason = DisputeReason.deliveryNotMet;
  final _descriptionCtrl = TextEditingController();
  final _responseCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<DisputeBloc>()
        .add(LoadDisputeEvent(bookingId: widget.bookingId));
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _responseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<DisputeBloc, DisputeState>(
        listener: (context, state) {
          if (state is DisputeLoadedState) {
            if (state.actionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Done!')),
              );
            } else if (state.actionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionError!.message)),
              );
            }
          }
        },
        builder: (context, state) => switch (state) {
          DisputeLoadingState() => const Center(child: AppLoader()),
          DisputeLoadedState(:final dispute, :final isActioning) =>
            dispute == null
                ? _OpenDisputeForm(
                    bookingId: widget.bookingId,
                    selectedReason: _selectedReason,
                    descriptionCtrl: _descriptionCtrl,
                    isActioning: isActioning,
                    onReasonChanged: (r) =>
                        setState(() => _selectedReason = r),
                  )
                : _DisputeDetailView(
                    dispute: dispute,
                    currentUserId: widget.currentUserId,
                    responseCtrl: _responseCtrl,
                    isActioning: isActioning,
                  ),
          DisputeErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<DisputeBloc>().add(
                          LoadDisputeEvent(bookingId: widget.bookingId),
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

class _OpenDisputeForm extends StatelessWidget {
  const _OpenDisputeForm({
    required this.bookingId,
    required this.selectedReason,
    required this.descriptionCtrl,
    required this.isActioning,
    required this.onReasonChanged,
  });

  final String bookingId;
  final DisputeReason selectedReason;
  final TextEditingController descriptionCtrl;
  final bool isActioning;
  final ValueChanged<DisputeReason> onReasonChanged;

  static const _reasons = [
    (label: 'Delivery Not Met', value: DisputeReason.deliveryNotMet),
    (label: 'Quality Issue', value: DisputeReason.qualityIssue),
    (label: 'Payment Issue', value: DisputeReason.paymentIssue),
    (label: 'No Show', value: DisputeReason.noShow),
    (label: 'Scope Change', value: DisputeReason.scopeChange),
    (label: 'Other', value: DisputeReason.other),
  ];

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
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Opening a dispute will pause this booking. Please try to resolve issues directly before raising a dispute.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Reason',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<DisputeReason>(
            value: selectedReason,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            items: _reasons
                .map((r) =>
                    DropdownMenuItem(value: r.value, child: Text(r.label)))
                .toList(),
            onChanged: (v) => onReasonChanged(v!),
          ),
          const SizedBox(height: 16),

          Text('Description',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe the issue in detail...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: isActioning
                ? null
                : () {
                    if (descriptionCtrl.text.trim().isEmpty) return;
                    context.read<DisputeBloc>().add(
                          OpenDisputeSubmitEvent(
                            bookingId: bookingId,
                            reason: selectedReason,
                            description: descriptionCtrl.text.trim(),
                          ),
                        );
                  },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: const Size.fromHeight(52)),
            child: isActioning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Open Dispute'),
          ),
        ],
      ),
    );
  }
}

class _DisputeDetailView extends StatelessWidget {
  const _DisputeDetailView({
    required this.dispute,
    required this.currentUserId,
    required this.responseCtrl,
    required this.isActioning,
  });

  final BookingDisputeEntity dispute;
  final String currentUserId;
  final TextEditingController responseCtrl;
  final bool isActioning;

  bool get _canRespond =>
      dispute.needsResponse && dispute.openedByUserId != currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) = _statusConfig(dispute.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.gavel_rounded, color: statusColor, size: 20),
                const SizedBox(width: 10),
                Text(statusLabel,
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _InfoItem(label: 'Opened By', value: dispute.openedByName),
          _InfoItem(
              label: 'Reason',
              value: _reasonLabel(dispute.reason)),
          _InfoItem(
              label: 'Opened',
              value:
                  '${dispute.createdAt.day}/${dispute.createdAt.month}/${dispute.createdAt.year}'),
          const SizedBox(height: 16),
          Text('Description',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(dispute.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),

          if (dispute.response != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text('Response from ${dispute.respondedByName ?? 'Other party'}',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(dispute.response!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],

          if (dispute.resolutionNotes != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text('Resolution',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(dispute.resolutionNotes!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],

          if (_canRespond) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('Your Response',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: responseCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Respond to this dispute...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isActioning
                  ? null
                  : () {
                      if (responseCtrl.text.trim().isEmpty) return;
                      context.read<DisputeBloc>().add(
                            RespondToDisputeSubmitEvent(
                              disputeId: dispute.id,
                              response: responseCtrl.text.trim(),
                            ),
                          );
                    },
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: isActioning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Response'),
            ),
          ],
        ],
      ),
    );
  }

  static (String, Color) _statusConfig(DisputeStatus s) => switch (s) {
        DisputeStatus.open => ('Open', Colors.deepOrange),
        DisputeStatus.underReview => ('Under Review', Colors.orange),
        DisputeStatus.resolved => ('Resolved', Colors.green),
        DisputeStatus.escalated => ('Escalated', Colors.red),
        DisputeStatus.closed => ('Closed', Colors.grey),
      };

  static String _reasonLabel(DisputeReason r) => switch (r) {
        DisputeReason.deliveryNotMet => 'Delivery Not Met',
        DisputeReason.qualityIssue => 'Quality Issue',
        DisputeReason.paymentIssue => 'Payment Issue',
        DisputeReason.noShow => 'No Show',
        DisputeReason.scopeChange => 'Scope Change',
        DisputeReason.other => 'Other',
      };
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
