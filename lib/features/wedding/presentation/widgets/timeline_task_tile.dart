import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';

class TimelineTaskTile extends StatelessWidget {
  final WeddingTimelineTaskEntity task;
  final ValueChanged<bool> onCompletedChanged;

  const TimelineTaskTile({
    super.key,
    required this.task,
    required this.onCompletedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (v) => onCompletedChanged(v ?? false),
          activeColor: theme.colorScheme.primary,
        ),
        title: Text(
          task.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                : null,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              isOverdue ? Icons.warning_amber : Icons.calendar_today_outlined,
              size: 12,
              color: isOverdue
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              DateFormat('MMM d, yyyy').format(task.dueDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverdue
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        trailing: _PriorityBadge(priority: task.priority),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      1 => ('High', Colors.red),
      2 => ('Med', Colors.orange),
      _ => ('Low', Colors.green),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
