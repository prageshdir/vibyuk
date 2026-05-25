import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_analytics_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_timeline_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_analytics_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class WeddingDashboardEvent extends Equatable {
  const WeddingDashboardEvent();
}

final class WeddingDashboardLoadRequested extends WeddingDashboardEvent {
  final String weddingId;
  const WeddingDashboardLoadRequested({required this.weddingId});

  @override
  List<Object?> get props => [weddingId];
}

final class WeddingDashboardRefreshRequested extends WeddingDashboardEvent {
  const WeddingDashboardRefreshRequested();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class WeddingDashboardState extends Equatable {
  const WeddingDashboardState();
}

final class WeddingDashboardInitial extends WeddingDashboardState {
  const WeddingDashboardInitial();

  @override
  List<Object?> get props => [];
}

final class WeddingDashboardLoading extends WeddingDashboardState {
  const WeddingDashboardLoading();

  @override
  List<Object?> get props => [];
}

final class WeddingDashboardLoaded extends WeddingDashboardState {
  final WeddingEntity wedding;
  final WeddingTimelineEntity timeline;
  final WeddingAnalyticsEntity analytics;
  final bool isRefreshing;

  const WeddingDashboardLoaded({
    required this.wedding,
    required this.timeline,
    required this.analytics,
    this.isRefreshing = false,
  });

  double get completionRate => timeline.completionRate;

  List<WeddingTimelineTaskEntity> get upcomingTasks =>
      timeline.upcomingTasks.take(5).toList();

  WeddingDashboardLoaded copyWith({
    WeddingEntity? wedding,
    WeddingTimelineEntity? timeline,
    WeddingAnalyticsEntity? analytics,
    bool? isRefreshing,
  }) =>
      WeddingDashboardLoaded(
        wedding: wedding ?? this.wedding,
        timeline: timeline ?? this.timeline,
        analytics: analytics ?? this.analytics,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [wedding, timeline, analytics, isRefreshing];
}

final class WeddingDashboardError extends WeddingDashboardState {
  final Failure failure;
  const WeddingDashboardError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class WeddingDashboardBloc
    extends BaseBloc<WeddingDashboardEvent, WeddingDashboardState> {
  WeddingDashboardBloc({
    required GetWeddingUseCase getWedding,
    required GetTimelineUseCase getTimeline,
    required GetWeddingAnalyticsUseCase getAnalytics,
  })  : _getWedding = getWedding,
        _getTimeline = getTimeline,
        _getAnalytics = getAnalytics,
        super(const WeddingDashboardInitial()) {
    on<WeddingDashboardLoadRequested>(_onLoadRequested);
    on<WeddingDashboardRefreshRequested>(_onRefreshRequested);
  }

  final GetWeddingUseCase _getWedding;
  final GetTimelineUseCase _getTimeline;
  final GetWeddingAnalyticsUseCase _getAnalytics;

  String? _currentWeddingId;

  Future<void> _onLoadRequested(
    WeddingDashboardLoadRequested event,
    Emitter<WeddingDashboardState> emit,
  ) async {
    _currentWeddingId = event.weddingId;
    emit(const WeddingDashboardLoading());
    await _fetch(event.weddingId, emit);
  }

  Future<void> _onRefreshRequested(
    WeddingDashboardRefreshRequested event,
    Emitter<WeddingDashboardState> emit,
  ) async {
    final id = _currentWeddingId;
    if (id == null) return;

    final current = state;
    if (current is WeddingDashboardLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const WeddingDashboardLoading());
    }

    await _fetch(id, emit);
  }

  Future<void> _fetch(
    String weddingId,
    Emitter<WeddingDashboardState> emit,
  ) async {
    final weddingResult = await _getWedding(WeddingIdParams(weddingId));

    WeddingEntity? wedding;
    final continueAfterWedding = weddingResult.fold(
      (f) {
        emit(WeddingDashboardError(failure: f));
        return false;
      },
      (w) {
        wedding = w;
        return true;
      },
    );
    if (!continueAfterWedding || wedding == null) return;

    final timelineResult = await _getTimeline(WeddingIdParams(weddingId));

    WeddingTimelineEntity? timeline;
    final continueAfterTimeline = timelineResult.fold(
      (f) {
        emit(WeddingDashboardError(failure: f));
        return false;
      },
      (t) {
        timeline = t;
        return true;
      },
    );
    if (!continueAfterTimeline || timeline == null) return;

    final analyticsResult = await _getAnalytics(WeddingIdParams(weddingId));
    analyticsResult.fold(
      (f) => emit(WeddingDashboardError(failure: f)),
      (a) => emit(WeddingDashboardLoaded(
        wedding: wedding!,
        timeline: timeline!,
        analytics: a,
      )),
    );
  }
}
