import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';

class AvailabilityCalendar extends StatelessWidget {
  const AvailabilityCalendar({
    super.key,
    required this.availability,
    required this.visibleMonth,
    this.onDayTap,
    this.onPreviousMonth,
    this.onNextMonth,
    this.isEditable = false,
  });

  final AvailabilityEntity availability;
  final DateTime visibleMonth;
  final void Function(DateTime, DayAvailability)? onDayTap;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final bool isEditable;

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth =
        DateUtils.getDaysInMonth(visibleMonth.year, visibleMonth.month);
    final firstWeekday =
        DateTime(visibleMonth.year, visibleMonth.month, 1).weekday; // 1=Mon

    return Column(
      children: [
        // Month header
        Row(
          children: [
            IconButton(
              onPressed: onPreviousMonth,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                _monthLabel(visibleMonth),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Weekday headers
        Row(
          children: _weekdays
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Day grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: (firstWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) return const SizedBox.shrink();
            final day = index - (firstWeekday - 2);
            final date = DateTime(visibleMonth.year, visibleMonth.month, day);
            final status = availability.statusFor(date);
            final isToday = DateUtils.isSameDay(date, DateTime.now());
            final isPast = date.isBefore(
                DateTime.now().subtract(const Duration(days: 1)));

            return GestureDetector(
              onTap: (!isPast && isEditable && onDayTap != null)
                  ? () => _showStatusPicker(context, date, status)
                  : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _dayColor(status, isPast),
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isToday ? FontWeight.w800 : FontWeight.w500,
                      color: _dayTextColor(status, isPast),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Legend
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
                color: _dayColor(DayAvailability.available, false),
                label: 'Available'),
            const SizedBox(width: 16),
            _LegendItem(
                color: _dayColor(DayAvailability.busy, false),
                label: 'Busy'),
            const SizedBox(width: 16),
            _LegendItem(
                color: _dayColor(DayAvailability.unavailable, false),
                label: 'Unavailable'),
          ],
        ),
      ],
    );
  }

  void _showStatusPicker(
      BuildContext context, DateTime date, DayAvailability current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(_monthLabel(date)),
              subtitle: const Text('Select availability'),
            ),
            const Divider(height: 1),
            for (final status in DayAvailability.values)
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: _dayColor(status, false), radius: 10),
                title: Text(status.name[0].toUpperCase() + status.name.substring(1)),
                trailing: current == status
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onDayTap?.call(date, status);
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _dayColor(DayAvailability status, bool isPast) {
    if (isPast) return Colors.transparent;
    return switch (status) {
      DayAvailability.available => Colors.green.withValues(alpha: 0.2),
      DayAvailability.busy => Colors.orange.withValues(alpha: 0.2),
      DayAvailability.unavailable => Colors.red.withValues(alpha: 0.2),
    };
  }

  Color _dayTextColor(DayAvailability status, bool isPast) {
    if (isPast) return Colors.grey;
    return switch (status) {
      DayAvailability.available => Colors.green.shade800,
      DayAvailability.busy => Colors.orange.shade800,
      DayAvailability.unavailable => Colors.red.shade800,
    };
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
