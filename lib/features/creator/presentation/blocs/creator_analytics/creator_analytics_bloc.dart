import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_analytics_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/analytics/get_creator_analytics_use_case.dart';

part 'creator_analytics_event.dart';
part 'creator_analytics_state.dart';

class CreatorAnalyticsBloc
    extends BaseBloc<CreatorAnalyticsEvent, CreatorAnalyticsState> {
  CreatorAnalyticsBloc({required GetCreatorAnalyticsUseCase getAnalytics})
      : _getAnalytics = getAnalytics,
        super(const CreatorAnalyticsInitialState()) {
    on<LoadCreatorAnalyticsEvent>(_onLoad);
    on<ChangePeriodEvent>(_onChangePeriod);
  }

  final GetCreatorAnalyticsUseCase _getAnalytics;

  Future<void> _onLoad(
      LoadCreatorAnalyticsEvent event, Emitter<CreatorAnalyticsState> emit) async {
    final period = event.period ?? 'last30days';
    emit(CreatorAnalyticsLoadingState(period: period));
    final result =
        await _getAnalytics(GetCreatorAnalyticsParams(period: period));
    result.fold(
      (f) => emit(CreatorAnalyticsErrorState(failure: f, period: period)),
      (a) => emit(CreatorAnalyticsLoadedState(analytics: a, period: period)),
    );
  }

  Future<void> _onChangePeriod(
      ChangePeriodEvent event, Emitter<CreatorAnalyticsState> emit) async {
    emit(CreatorAnalyticsLoadingState(period: event.period));
    final result =
        await _getAnalytics(GetCreatorAnalyticsParams(period: event.period));
    result.fold(
      (f) => emit(CreatorAnalyticsErrorState(failure: f, period: event.period)),
      (a) => emit(
          CreatorAnalyticsLoadedState(analytics: a, period: event.period)),
    );
  }
}
