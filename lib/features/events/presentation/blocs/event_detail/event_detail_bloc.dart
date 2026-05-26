import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/usecases/get_event_detail_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/publish_event_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class EventDetailEvent extends Equatable {
  const EventDetailEvent();
}

final class EventDetailLoadRequested extends EventDetailEvent {
  final String eventId;
  const EventDetailLoadRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

final class EventDetailRefreshRequested extends EventDetailEvent {
  const EventDetailRefreshRequested();

  @override
  List<Object?> get props => [];
}

final class EventDetailPublishRequested extends EventDetailEvent {
  const EventDetailPublishRequested();

  @override
  List<Object?> get props => [];
}

final class EventDetailCancelRequested extends EventDetailEvent {
  final String reason;
  const EventDetailCancelRequested({required this.reason});

  @override
  List<Object?> get props => [reason];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class EventDetailState extends Equatable {
  const EventDetailState();
}

final class EventDetailInitial extends EventDetailState {
  const EventDetailInitial();

  @override
  List<Object?> get props => [];
}

final class EventDetailLoading extends EventDetailState {
  const EventDetailLoading();

  @override
  List<Object?> get props => [];
}

final class EventDetailLoaded extends EventDetailState {
  final EventEntity event;
  final bool isPublishing;
  final bool isCancelling;

  const EventDetailLoaded({
    required this.event,
    this.isPublishing = false,
    this.isCancelling = false,
  });

  EventDetailLoaded copyWith({
    EventEntity? event,
    bool? isPublishing,
    bool? isCancelling,
  }) =>
      EventDetailLoaded(
        event: event ?? this.event,
        isPublishing: isPublishing ?? this.isPublishing,
        isCancelling: isCancelling ?? this.isCancelling,
      );

  @override
  List<Object?> get props => [event, isPublishing, isCancelling];
}

final class EventDetailError extends EventDetailState {
  final Failure failure;
  const EventDetailError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class EventDetailBloc extends BaseBloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc({
    required GetEventDetailUseCase getEventDetail,
    required PublishEventUseCase publishEvent,
  })  : _getEventDetail = getEventDetail,
        _publishEvent = publishEvent,
        super(const EventDetailInitial()) {
    on<EventDetailLoadRequested>(_onLoadRequested);
    on<EventDetailRefreshRequested>(_onRefreshRequested);
    on<EventDetailPublishRequested>(_onPublishRequested);
    on<EventDetailCancelRequested>(_onCancelRequested);
  }

  final GetEventDetailUseCase _getEventDetail;
  final PublishEventUseCase _publishEvent;

  String? _currentEventId;

  Future<void> _onLoadRequested(
    EventDetailLoadRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    _currentEventId = event.eventId;
    emit(const EventDetailLoading());
    final result = await _getEventDetail(EventIdParams(event.eventId));
    result.fold(
      (failure) => emit(EventDetailError(failure: failure)),
      (entity) => emit(EventDetailLoaded(event: entity)),
    );
  }

  Future<void> _onRefreshRequested(
    EventDetailRefreshRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    final id = _currentEventId;
    if (id == null) return;
    final result = await _getEventDetail(EventIdParams(id));
    result.fold(
      (failure) => emit(EventDetailError(failure: failure)),
      (entity) => emit(EventDetailLoaded(event: entity)),
    );
  }

  Future<void> _onPublishRequested(
    EventDetailPublishRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    final current = state;
    if (current is! EventDetailLoaded) return;
    emit(current.copyWith(isPublishing: true));
    final result = await _publishEvent(EventIdParams(current.event.id));
    result.fold(
      (failure) => emit(EventDetailError(failure: failure)),
      (entity) => emit(EventDetailLoaded(event: entity)),
    );
  }

  Future<void> _onCancelRequested(
    EventDetailCancelRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    // No CancelEventUseCase exists yet — surface a clear failure so the UI
    // can handle it gracefully until the use-case is implemented.
    emit(const EventDetailError(
      failure: ServerFailure(
        message: 'Cancel event is not yet implemented.',
        code: 'NOT_IMPLEMENTED',
      ),
    ));
  }
}
