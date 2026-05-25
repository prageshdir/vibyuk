import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/event_analytics_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/usecases/get_event_analytics_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/get_event_detail_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class EventDashboardEvent extends Equatable {
  const EventDashboardEvent();
}

final class EventDashboardLoadRequested extends EventDashboardEvent {
  final String eventId;
  const EventDashboardLoadRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

final class EventDashboardRefreshRequested extends EventDashboardEvent {
  const EventDashboardRefreshRequested();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class EventDashboardState extends Equatable {
  const EventDashboardState();
}

final class EventDashboardInitial extends EventDashboardState {
  const EventDashboardInitial();

  @override
  List<Object?> get props => [];
}

final class EventDashboardLoading extends EventDashboardState {
  const EventDashboardLoading();

  @override
  List<Object?> get props => [];
}

final class EventDashboardLoaded extends EventDashboardState {
  final EventEntity event;
  final EventAnalyticsEntity analytics;
  final bool isRefreshing;

  const EventDashboardLoaded({
    required this.event,
    required this.analytics,
    this.isRefreshing = false,
  });

  EventDashboardLoaded copyWith({
    EventEntity? event,
    EventAnalyticsEntity? analytics,
    bool? isRefreshing,
  }) =>
      EventDashboardLoaded(
        event: event ?? this.event,
        analytics: analytics ?? this.analytics,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [event, analytics, isRefreshing];
}

final class EventDashboardError extends EventDashboardState {
  final Failure failure;
  const EventDashboardError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class EventDashboardBloc
    extends BaseBloc<EventDashboardEvent, EventDashboardState> {
  EventDashboardBloc({
    required GetEventDetailUseCase getEventDetail,
    required GetEventAnalyticsUseCase getAnalytics,
  })  : _getEventDetail = getEventDetail,
        _getAnalytics = getAnalytics,
        super(const EventDashboardInitial()) {
    on<EventDashboardLoadRequested>(_onLoadRequested);
    on<EventDashboardRefreshRequested>(_onRefreshRequested);
  }

  final GetEventDetailUseCase _getEventDetail;
  final GetEventAnalyticsUseCase _getAnalytics;

  String? _currentEventId;

  Future<void> _onLoadRequested(
    EventDashboardLoadRequested event,
    Emitter<EventDashboardState> emit,
  ) async {
    _currentEventId = event.eventId;
    emit(const EventDashboardLoading());
    await _fetch(event.eventId, emit);
  }

  Future<void> _onRefreshRequested(
    EventDashboardRefreshRequested event,
    Emitter<EventDashboardState> emit,
  ) async {
    final id = _currentEventId;
    if (id == null) return;

    final current = state;
    if (current is EventDashboardLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const EventDashboardLoading());
    }

    await _fetch(id, emit);
  }

  Future<void> _fetch(String eventId, Emitter<EventDashboardState> emit) async {
    final eventResult = await _getEventDetail(EventIdParams(eventId));

    EventEntity? event;
    final shouldContinue = eventResult.fold(
      (failure) {
        emit(EventDashboardError(failure: failure));
        return false;
      },
      (e) {
        event = e;
        return true;
      },
    );
    if (!shouldContinue || event == null) return;

    final analyticsResult = await _getAnalytics(EventIdParams(eventId));
    analyticsResult.fold(
      (failure) => emit(EventDashboardError(failure: failure)),
      (analytics) => emit(EventDashboardLoaded(
        event: event!,
        analytics: analytics,
      )),
    );
  }
}
