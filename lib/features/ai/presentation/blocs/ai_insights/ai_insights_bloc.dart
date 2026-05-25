import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_ai_insights_usecase.dart';
import 'ai_insights_event.dart';
import 'ai_insights_state.dart';

class AiInsightsBloc extends BaseBloc<AiInsightsEvent, AiInsightsState> {
  final GetAiInsightsUseCase _getInsights;
  final DismissInsightUseCase _dismissInsight;

  AiInsightsBloc({
    required GetAiInsightsUseCase getInsights,
    required DismissInsightUseCase dismissInsight,
  })  : _getInsights = getInsights,
        _dismissInsight = dismissInsight,
        super(const AiInsightsState()) {
    on<LoadInsights>(_onLoad);
    on<DismissInsight>(_onDismiss);
    on<RefreshInsights>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadInsights event,
    Emitter<AiInsightsState> emit,
  ) async {
    emit(state.copyWith(status: AiInsightsStatus.loading));
    final result = await _getInsights();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: AiInsightsStatus.failure, failure: failure)),
      (data) => emit(state.copyWith(
        status: AiInsightsStatus.success,
        insights: data,
        failure: null,
      )),
    );
  }

  Future<void> _onDismiss(
    DismissInsight event,
    Emitter<AiInsightsState> emit,
  ) async {
    final dismissing = {...state.dismissingIds, event.insightId};
    emit(state.copyWith(dismissingIds: dismissing));

    final result =
        await _dismissInsight(DismissInsightParams(insightId: event.insightId));

    final updated = {...state.dismissingIds}..remove(event.insightId);

    result.fold(
      (failure) => emit(state.copyWith(dismissingIds: updated, failure: failure)),
      (_) {
        final remaining =
            state.insights.where((i) => i.id != event.insightId).toList();
        emit(state.copyWith(
          insights: remaining,
          dismissingIds: updated,
          failure: null,
        ));
      },
    );
  }

  Future<void> _onRefresh(
    RefreshInsights event,
    Emitter<AiInsightsState> emit,
  ) async {
    add(const LoadInsights());
  }
}
