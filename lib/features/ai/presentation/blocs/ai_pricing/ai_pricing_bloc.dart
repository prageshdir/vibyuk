import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_pricing_suggestions_usecase.dart';
import 'ai_pricing_event.dart';
import 'ai_pricing_state.dart';

class AiPricingBloc extends BaseBloc<AiPricingEvent, AiPricingState> {
  final GetPricingSuggestionUseCase _getPricing;
  final GetAllPricingSuggestionsUseCase _getAllPricing;

  AiPricingBloc({
    required GetPricingSuggestionUseCase getPricing,
    required GetAllPricingSuggestionsUseCase getAllPricing,
  })  : _getPricing = getPricing,
        _getAllPricing = getAllPricing,
        super(const AiPricingState()) {
    on<LoadAllPricingSuggestions>(_onLoadAll);
    on<GetPricingSuggestion>(_onGetSingle);
    on<SelectServiceType>(_onSelectType);
  }

  Future<void> _onLoadAll(
    LoadAllPricingSuggestions event,
    Emitter<AiPricingState> emit,
  ) async {
    emit(state.copyWith(status: AiPricingStatus.loading));
    final result = await _getAllPricing();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: AiPricingStatus.failure, failure: failure)),
      (data) => emit(state.copyWith(
        status: AiPricingStatus.success,
        suggestions: data,
        activeSuggestion: data.isNotEmpty ? data.first : null,
        failure: null,
      )),
    );
  }

  Future<void> _onGetSingle(
    GetPricingSuggestion event,
    Emitter<AiPricingState> emit,
  ) async {
    emit(state.copyWith(status: AiPricingStatus.loading));
    final result = await _getPricing(
      PricingParams(
        serviceType: event.serviceType,
        location: event.location,
        experienceYears: event.experienceYears,
        additionalFactors: event.additionalFactors,
      ),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(status: AiPricingStatus.failure, failure: failure)),
      (suggestion) {
        final updated = [
          suggestion,
          ...state.suggestions.where((s) => s.id != suggestion.id),
        ];
        emit(state.copyWith(
          status: AiPricingStatus.success,
          suggestions: updated,
          activeSuggestion: suggestion,
          failure: null,
        ));
      },
    );
  }

  void _onSelectType(SelectServiceType event, Emitter<AiPricingState> emit) {
    final match = state.suggestions
        .where((s) => s.serviceType == event.serviceType)
        .firstOrNull;
    emit(state.copyWith(
      selectedServiceType: event.serviceType,
      activeSuggestion: match ?? state.activeSuggestion,
    ));
  }
}
