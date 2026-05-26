import 'package:equatable/equatable.dart';

enum TimelinePhase {
  planning,
  booking,
  confirmed,
  preparation,
  dayOf,
  postWedding,
}

class WeddingTimelineTaskEntity extends Equatable {
  const WeddingTimelineTaskEntity({
    required this.id,
    required this.weddingId,
    required this.title,
    required this.phase,
    required this.dueDate,
    required this.isCompleted,
    required this.priority,
    this.description,
    this.completedDate,
    this.vendorId,
  });

  final String id;
  final String weddingId;
  final String title;
  final String? description;
  final TimelinePhase phase;
  final DateTime dueDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final String? vendorId;
  final int priority;

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        weddingId,
        title,
        description,
        phase,
        dueDate,
        completedDate,
        isCompleted,
        vendorId,
        priority,
      ];
}

class WeddingTimelineEntity extends Equatable {
  const WeddingTimelineEntity({
    required this.weddingId,
    required this.tasks,
  });

  final String weddingId;
  final List<WeddingTimelineTaskEntity> tasks;

  Map<TimelinePhase, List<WeddingTimelineTaskEntity>> get tasksByPhase {
    final map = <TimelinePhase, List<WeddingTimelineTaskEntity>>{};
    for (final phase in TimelinePhase.values) {
      map[phase] = tasks.where((t) => t.phase == phase).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    return map;
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get totalCount => tasks.length;

  double get completionRate =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  List<WeddingTimelineTaskEntity> get upcomingTasks => tasks
      .where((t) => !t.isCompleted)
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  @override
  List<Object?> get props => [weddingId, tasks];
}
