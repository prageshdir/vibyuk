import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class UpdateTimelineTaskUseCase
    extends UseCase<WeddingTimelineEntity, UpdateTimelineTaskParams> {
  const UpdateTimelineTaskUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingTimelineEntity>> call(
    UpdateTimelineTaskParams params,
  ) {
    final data = <String, dynamic>{
      if (params.title != null) 'title': params.title,
      if (params.description != null) 'description': params.description,
      if (params.isCompleted != null) 'is_completed': params.isCompleted,
      if (params.dueDate != null) 'due_date': params.dueDate!.toIso8601String(),
      if (params.priority != null) 'priority': params.priority,
    };
    return _repository.updateTimelineTask(params.weddingId, params.taskId, data);
  }
}

class UpdateTimelineTaskParams extends Equatable {
  const UpdateTimelineTaskParams({
    required this.weddingId,
    required this.taskId,
    this.title,
    this.description,
    this.isCompleted,
    this.dueDate,
    this.priority,
  });

  final String weddingId;
  final String taskId;
  final String? title;
  final String? description;
  final bool? isCompleted;
  final DateTime? dueDate;
  final int? priority;

  @override
  List<Object?> get props => [
        weddingId,
        taskId,
        title,
        description,
        isCompleted,
        dueDate,
        priority,
      ];
}
