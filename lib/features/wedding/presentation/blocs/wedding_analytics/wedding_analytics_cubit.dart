import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_analytics_entity.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_analytics_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_usecase.dart';

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class WeddingAnalyticsState extends Equatable {
  const WeddingAnalyticsState();
}

final class WeddingAnalyticsInitial extends WeddingAnalyticsState {
  const WeddingAnalyticsInitial();

  @override
  List<Object?> get props => [];
}

final class WeddingAnalyticsLoading extends WeddingAnalyticsState {
  const WeddingAnalyticsLoading();

  @override
  List<Object?> get props => [];
}

final class WeddingAnalyticsLoaded extends WeddingAnalyticsState {
  final WeddingAnalyticsEntity analytics;
  const WeddingAnalyticsLoaded({required this.analytics});

  @override
  List<Object?> get props => [analytics];
}

final class WeddingAnalyticsError extends WeddingAnalyticsState {
  final Failure failure;
  const WeddingAnalyticsError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class WeddingAnalyticsCubit extends BaseCubit<WeddingAnalyticsState> {
  WeddingAnalyticsCubit({required GetWeddingAnalyticsUseCase getAnalytics})
      : _getAnalytics = getAnalytics,
        super(const WeddingAnalyticsInitial());

  final GetWeddingAnalyticsUseCase _getAnalytics;

  Future<void> load(String weddingId) async {
    emit(const WeddingAnalyticsLoading());
    final result = await _getAnalytics(WeddingIdParams(weddingId));
    result.fold(
      (f) => emit(WeddingAnalyticsError(failure: f)),
      (a) => emit(WeddingAnalyticsLoaded(analytics: a)),
    );
  }
}
