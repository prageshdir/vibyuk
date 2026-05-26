import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class AddTimelineTaskUseCase
    extends UseCase<WeddingTimelineEntity, AddTimelineTaskParams> {
  const AddTimelineTaskUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingTimelineEntity>> call(
    AddTimelineTaskParams params,
  ) {
    final data = <String, dynamic>{
      'title': params.title,
      'phase': params.phase,
      'due_date': params.dueDate.toIso8601String(),
      'priority': params.priority,
      if (params.description != null) 'description': params.description,
      if (params.vendorId != null) 'vendor_id': params.vendorId,
    };
    return _repository.addTimelineTask(params.weddingId, data);
  }
}

class AddTimelineTaskParams extends Equatable {
  const AddTimelineTaskParams({
    required this.weddingId,
    required this.title,
    required this.phase,
    required this.dueDate,
    this.description,
    this.priority = 2,
    this.vendorId,
  });

  final String weddingId;
  final String title;
  final String phase;
  final DateTime dueDate;
  final String? description;
  final int priority;
  final String? vendorId;

  @override
  List<Object?> get props => [
        weddingId,
        title,
        phase,
        dueDate,
        description,
        priority,
        vendorId,
      ];
}
