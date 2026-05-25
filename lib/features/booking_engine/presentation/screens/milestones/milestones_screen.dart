import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/milestone/milestone_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/widgets/milestone_card.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({
    super.key,
    required this.bookingId,
    required this.isCreator,
  });

  final String bookingId;
  final bool isCreator;

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<MilestoneBloc>()
        .add(LoadMilestonesEvent(bookingId: widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<MilestoneBloc, MilestoneState>(
        listener: (context, state) {
          if (state is MilestoneLoadedState && state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionError!.message)),
            );
          }
        },
        builder: (context, state) => switch (state) {
          MilestoneLoadingState() => const Center(child: AppLoader()),
          MilestoneLoadedState(
            :final milestones,
            :final isActioning,
            :final actioningMilestoneId
          ) =>
            milestones.isEmpty
                ? const _EmptyMilestones()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: milestones.length,
                    itemBuilder: (context, i) {
                      final m = milestones[i];
                      final isThisActioning =
                          isActioning && actioningMilestoneId == m.id;
                      return MilestoneCard(
                        milestone: m,
                        isActioning: isThisActioning,
                        onSubmit: widget.isCreator && m.isPending
                            ? () => _showSubmitDialog(context, m.id)
                            : null,
                        onApprove: !widget.isCreator && m.isSubmitted
                            ? () => context.read<MilestoneBloc>().add(
                                  ApproveMilestoneDeliverableEvent(
                                    bookingId: widget.bookingId,
                                    milestoneId: m.id,
                                  ),
                                )
                            : null,
                        onReject: !widget.isCreator && m.isSubmitted
                            ? () => _showRejectDialog(context, m.id)
                            : null,
                      );
                    },
                  ),
          MilestoneErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<MilestoneBloc>()
                        .add(LoadMilestonesEvent(
                            bookingId: widget.bookingId)),
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

  void _showSubmitDialog(BuildContext context, String milestoneId) {
    final urlCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Deliverable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                  labelText: 'Deliverable URL',
                  hintText: 'https://...'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration:
                  const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (urlCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              context.read<MilestoneBloc>().add(
                    SubmitMilestoneDeliverableEvent(
                      bookingId: widget.bookingId,
                      milestoneId: milestoneId,
                      deliverableUrl: urlCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                    ),
                  );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String milestoneId) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Deliverable'),
        content: TextField(
          controller: reasonCtrl,
          decoration:
              const InputDecoration(labelText: 'Rejection reason'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              context.read<MilestoneBloc>().add(
                    RejectMilestoneDeliverableEvent(
                      bookingId: widget.bookingId,
                      milestoneId: milestoneId,
                      reason: reasonCtrl.text.trim(),
                    ),
                  );
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _EmptyMilestones extends StatelessWidget {
  const _EmptyMilestones();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt_rounded,
              size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No milestones',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
