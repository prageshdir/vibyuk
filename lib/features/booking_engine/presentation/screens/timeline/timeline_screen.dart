import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/timeline/timeline_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/widgets/booking_timeline_item.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<TimelineBloc>()
        .add(LoadTimelineEvent(bookingId: widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<TimelineBloc, TimelineState>(
        builder: (context, state) => switch (state) {
          TimelineLoadingState() => const Center(child: AppLoader()),
          TimelineLoadedState(:final events) => events.isEmpty
              ? const _EmptyTimeline()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, i) => BookingTimelineItem(
                    event: events[i],
                    isLast: i == events.length - 1,
                  ),
                ),
          TimelineErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<TimelineBloc>().add(
                          LoadTimelineEvent(bookingId: widget.bookingId),
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

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No timeline events',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
