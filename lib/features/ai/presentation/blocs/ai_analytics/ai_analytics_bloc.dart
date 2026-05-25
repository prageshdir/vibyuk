import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_ai_analytics_usecase.dart';
import 'ai_analytics_event.dart';
import 'ai_analytics_state.dart';

class AiAnalyticsBloc extends BaseBloc<AiAnalyticsEvent, AiAnalyticsState> {
  final GetAiAnalyticsUseCase _getAnalytics;

  AiAnalyticsBloc({required GetAiAnalyticsUseCase getAnalytics})
      : _getAnalytics = getAnalytics,
        super(const AiAnalyticsState()) {
    on<LoadAnalytics>(_onLoad);
    on<ChangePeriod>(_onChangePeriod);
    on<RefreshAnalytics>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadAnalytics event,
    Emitter<AiAnalyticsState> emit,
  ) async {
    emit(state.copyWith(
      status: AiAnalyticsStatus.loading,
      selectedPeriod: event.period,
    ));
    final result = await _getAnalytics(AnalyticsParams(period: event.period));
    result.fold(
      (failure) =>
          emit(state.copyWith(status: AiAnalyticsStatus.failure, failure: failure)),
      (data) => emit(state.copyWith(
        status: AiAnalyticsStatus.success,
        analytics: data,
        failure: null,
      )),
    );
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<AiAnalyticsState> emit,
  ) async {
    if (state.selectedPeriod == event.period) return;
    add(LoadAnalytics(period: event.period));
  }

  Future<void> _onRefresh(
    RefreshAnalytics event,
    Emitter<AiAnalyticsState> emit,
  ) async {
    add(LoadAnalytics(period: state.selectedPeriod));
  }
}
