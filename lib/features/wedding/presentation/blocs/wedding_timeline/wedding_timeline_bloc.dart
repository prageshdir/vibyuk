import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/usecases/add_timeline_task_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_timeline_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/update_timeline_task_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class WeddingTimelineEvent extends Equatable {
  const WeddingTimelineEvent();
}

final class WeddingTimelineLoadRequested extends WeddingTimelineEvent {
  final String weddingId;
  const WeddingTimelineLoadRequested({required this.weddingId});

  @override
  List<Object?> get props => [weddingId];
}

final class WeddingTimelineTaskCompleted extends WeddingTimelineEvent {
  final String taskId;
  final bool isCompleted;
  const WeddingTimelineTaskCompleted({
    required this.taskId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [taskId, isCompleted];
}

final class WeddingTimelineTaskAdded extends WeddingTimelineEvent {
  final String title;
  final String phase;
  final DateTime dueDate;
  final String? description;
  final int priority;

  const WeddingTimelineTaskAdded({
    required this.title,
    required this.phase,
    required this.dueDate,
    this.description,
    this.priority = 2,
  });

  @override
  List<Object?> get props => [title, phase, dueDate, description, priority];
}

final class WeddingTimelineRefreshRequested extends WeddingTimelineEvent {
  const WeddingTimelineRefreshRequested();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class WeddingTimelineState extends Equatable {
  const WeddingTimelineState();
}

final class WeddingTimelineInitial extends WeddingTimelineState {
  const WeddingTimelineInitial();

  @override
  List<Object?> get props => [];
}

final class WeddingTimelineLoading extends WeddingTimelineState {
  const WeddingTimelineLoading();

  @override
  List<Object?> get props => [];
}

final class WeddingTimelineLoaded extends WeddingTimelineState {
  final WeddingTimelineEntity timeline;
  final bool isUpdating;

  const WeddingTimelineLoaded({required this.timeline, this.isUpdating = false});

  WeddingTimelineLoaded copyWith({
    WeddingTimelineEntity? timeline,
    bool? isUpdating,
  }) =>
      WeddingTimelineLoaded(
        timeline: timeline ?? this.timeline,
        isUpdating: isUpdating ?? this.isUpdating,
      );

  @override
  List<Object?> get props => [timeline, isUpdating];
}

final class WeddingTimelineError extends WeddingTimelineState {
  final Failure failure;
  const WeddingTimelineError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class WeddingTimelineBloc
    extends BaseBloc<WeddingTimelineEvent, WeddingTimelineState> {
  WeddingTimelineBloc({
    required GetTimelineUseCase getTimeline,
    required UpdateTimelineTaskUseCase updateTask,
    required AddTimelineTaskUseCase addTask,
  })  : _getTimeline = getTimeline,
        _updateTask = updateTask,
        _addTask = addTask,
        super(const WeddingTimelineInitial()) {
    on<WeddingTimelineLoadRequested>(_onLoadRequested);
    on<WeddingTimelineTaskCompleted>(_onTaskCompleted);
    on<WeddingTimelineTaskAdded>(_onTaskAdded);
    on<WeddingTimelineRefreshRequested>(_onRefreshRequested);
  }

  final GetTimelineUseCase _getTimeline;
  final UpdateTimelineTaskUseCase _updateTask;
  final AddTimelineTaskUseCase _addTask;

  String? _weddingId;

  Future<void> _onLoadRequested(
    WeddingTimelineLoadRequested event,
    Emitter<WeddingTimelineState> emit,
  ) async {
    _weddingId = event.weddingId;
    emit(const WeddingTimelineLoading());
    final result = await _getTimeline(WeddingIdParams(event.weddingId));
    result.fold(
      (f) => emit(WeddingTimelineError(failure: f)),
      (timeline) => emit(WeddingTimelineLoaded(timeline: timeline)),
    );
  }

  Future<void> _onTaskCompleted(
    WeddingTimelineTaskCompleted event,
    Emitter<WeddingTimelineState> emit,
  ) async {
    final current = state;
    if (current is! WeddingTimelineLoaded || _weddingId == null) return;

    emit(current.copyWith(isUpdating: true));
    final result = await _updateTask(UpdateTimelineTaskParams(
      weddingId: _weddingId!,
      taskId: event.taskId,
      isCompleted: event.isCompleted,
    ));
    result.fold(
      (f) => emit(WeddingTimelineError(failure: f)),
      (timeline) => emit(WeddingTimelineLoaded(timeline: timeline)),
    );
  }

  Future<void> _onTaskAdded(
    WeddingTimelineTaskAdded event,
    Emitter<WeddingTimelineState> emit,
  ) async {
    final current = state;
    if (current is! WeddingTimelineLoaded || _weddingId == null) return;

    emit(current.copyWith(isUpdating: true));
    final result = await _addTask(AddTimelineTaskParams(
      weddingId: _weddingId!,
      title: event.title,
      phase: event.phase,
      dueDate: event.dueDate,
      description: event.description,
      priority: event.priority,
    ));
    result.fold(
      (f) => emit(WeddingTimelineError(failure: f)),
      (timeline) => emit(WeddingTimelineLoaded(timeline: timeline)),
    );
  }

  Future<void> _onRefreshRequested(
    WeddingTimelineRefreshRequested event,
    Emitter<WeddingTimelineState> emit,
  ) async {
    final id = _weddingId;
    if (id == null) return;
    final result = await _getTimeline(WeddingIdParams(id));
    result.fold(
      (f) => emit(WeddingTimelineError(failure: f)),
      (timeline) => emit(WeddingTimelineLoaded(timeline: timeline)),
    );
  }
}
