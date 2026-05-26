import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/availability/availability_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/availability_calendar.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AvailabilityBloc>().add(const LoadAvailabilityEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<AvailabilityBloc, AvailabilityState>(
        builder: (context, state) => switch (state) {
          AvailabilityLoadingState() => const Center(child: AppLoader()),
          AvailabilityLoadedState(:final availability, :final visibleMonth) =>
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AvailabilityCalendar(
                        availability: availability,
                        visibleMonth: visibleMonth,
                        isEditable: true,
                        onDayTap: (date, status) {
                          context.read<AvailabilityBloc>().add(
                                UpdateDayAvailabilityEvent(
                                    date: date, status: status),
                              );
                        },
                        onPreviousMonth: () {
                          final s = context.read<AvailabilityBloc>().state;
                          if (s is AvailabilityLoadedState) {
                            final prev = DateTime(
                                s.visibleMonth.year,
                                s.visibleMonth.month - 1);
                            context.read<AvailabilityBloc>().emit(
                                s.copyWith(visibleMonth: prev));
                          }
                        },
                        onNextMonth: () {
                          final s = context.read<AvailabilityBloc>().state;
                          if (s is AvailabilityLoadedState) {
                            final next = DateTime(
                                s.visibleMonth.year,
                                s.visibleMonth.month + 1);
                            context.read<AvailabilityBloc>().emit(
                                s.copyWith(visibleMonth: next));
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Weekly Schedule',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _WeeklySlotsList(
                    slots: availability.defaultWeeklySlots,
                    onSave: (slots) => context.read<AvailabilityBloc>().add(
                          UpdateWeeklySlotsEvent(slots: slots),
                        ),
                  ),
                ],
              ),
            ),
          AvailabilityErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<AvailabilityBloc>()
                        .add(const LoadAvailabilityEvent()),
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

class _WeeklySlotsList extends StatefulWidget {
  const _WeeklySlotsList({required this.slots, required this.onSave});
  final List<TimeSlotEntity> slots;
  final void Function(List<TimeSlotEntity>) onSave;

  @override
  State<_WeeklySlotsList> createState() => _WeeklySlotsListState();
}

class _WeeklySlotsListState extends State<_WeeklySlotsList> {
  late List<TimeSlotEntity> _slots;
  bool _isDirty = false;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _slots = List.from(widget.slots);
  }

  bool _hasSlot(int weekday) => _slots.any((s) => s.weekday == weekday);

  void _toggleDay(int weekday) {
    setState(() {
      if (_hasSlot(weekday)) {
        _slots.removeWhere((s) => s.weekday == weekday);
      } else {
        _slots.add(TimeSlotEntity(
            weekday: weekday,
            startHour: 9,
            startMinute: 0,
            endHour: 17,
            endMinute: 0));
      }
      _isDirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(7, (i) {
          final weekday = i + 1;
          final hasSlot = _hasSlot(weekday);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Checkbox(
                value: hasSlot,
                onChanged: (_) => _toggleDay(weekday),
              ),
              title: Text(_weekdays[i]),
              subtitle: hasSlot
                  ? () {
                      final slot =
                          _slots.firstWhere((s) => s.weekday == weekday);
                      return Text(
                          '${slot.displayStart} – ${slot.displayEnd}');
                    }()
                  : const Text('Not available'),
            ),
          );
        }),
        if (_isDirty) ...[
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              widget.onSave(_slots);
              setState(() => _isDirty = false);
            },
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Save Schedule'),
          ),
        ],
      ],
    );
  }
}
