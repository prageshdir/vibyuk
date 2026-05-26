import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_analytics_entity.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_tourism_analytics_usecase.dart';

// ── State ─────────────────────────────────────────────────────────────────────

final class TourismAnalyticsState extends Equatable {
  const TourismAnalyticsState({
    this.status = TourismAnalyticsStatus.initial,
    this.analytics,
    this.from,
    this.to,
    this.errorMessage,
  });

  final TourismAnalyticsStatus status;
  final TourismAnalyticsEntity? analytics;
  final DateTime? from;
  final DateTime? to;
  final String? errorMessage;

  TourismAnalyticsState copyWith({
    TourismAnalyticsStatus? status,
    TourismAnalyticsEntity? analytics,
    DateTime? from,
    DateTime? to,
    String? errorMessage,
  }) =>
      TourismAnalyticsState(
        status: status ?? this.status,
        analytics: analytics ?? this.analytics,
        from: from ?? this.from,
        to: to ?? this.to,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, analytics, from, to, errorMessage];
}

enum TourismAnalyticsStatus { initial, loading, loaded, error }

// ── Cubit ─────────────────────────────────────────────────────────────────────

class TourismAnalyticsCubit extends BaseCubit<TourismAnalyticsState> {
  TourismAnalyticsCubit({required GetTourismAnalyticsUseCase getAnalytics})
      : _getAnalytics = getAnalytics,
        super(const TourismAnalyticsState());

  final GetTourismAnalyticsUseCase _getAnalytics;

  Future<void> load({DateTime? from, DateTime? to}) async {
    emit(state.copyWith(
      status: TourismAnalyticsStatus.loading,
      from: from,
      to: to,
    ));

    final result = await _getAnalytics(
        GetTourismAnalyticsParams(from: from, to: to));

    result.fold(
      (failure) => emit(state.copyWith(
        status: TourismAnalyticsStatus.error,
        errorMessage: failure.message,
      )),
      (analytics) => emit(state.copyWith(
        status: TourismAnalyticsStatus.loaded,
        analytics: analytics,
      )),
    );
  }

  Future<void> refresh() => load(from: state.from, to: state.to);
}
