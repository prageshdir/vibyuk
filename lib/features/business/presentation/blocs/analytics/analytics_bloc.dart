import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/analytics_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/analytics/get_analytics_dashboard_use_case.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends BaseBloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required GetAnalyticsDashboardUseCase getAnalyticsDashboard})
      : _getDashboard = getAnalyticsDashboard,
        super(const AnalyticsInitialState()) {
    on<LoadAnalyticsDashboardEvent>(_onLoad);
    on<ChangePeriodEvent>(_onChangePeriod);
  }

  final GetAnalyticsDashboardUseCase _getDashboard;

  Future<void> _onLoad(
      LoadAnalyticsDashboardEvent event, Emitter<AnalyticsState> emit) async {
    emit(const AnalyticsLoadingState());
    final result = await _getDashboard(
        GetAnalyticsDashboardParams(period: event.period));
    result.fold(
      (f) => emit(AnalyticsErrorState(failure: f)),
      (d) => emit(AnalyticsLoadedState(dashboard: d, selectedPeriod: event.period)),
    );
  }

  void _onChangePeriod(ChangePeriodEvent event, Emitter<AnalyticsState> emit) {
    add(LoadAnalyticsDashboardEvent(period: event.period));
  }
}
