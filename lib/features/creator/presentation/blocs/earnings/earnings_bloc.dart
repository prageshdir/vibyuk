import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_earnings_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/earnings/get_creator_earnings_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/earnings/request_payout_use_case.dart';

part 'earnings_event.dart';
part 'earnings_state.dart';

class EarningsBloc extends BaseBloc<EarningsEvent, EarningsState> {
  EarningsBloc({
    required GetCreatorEarningsUseCase getEarnings,
    required RequestPayoutUseCase requestPayout,
  })  : _getEarnings = getEarnings,
        _requestPayout = requestPayout,
        super(const EarningsInitialState()) {
    on<LoadEarningsEvent>(_onLoad);
    on<ChangePeriodEvent>(_onChangePeriod);
    on<RequestPayoutEvent>(_onRequestPayout);
  }

  final GetCreatorEarningsUseCase _getEarnings;
  final RequestPayoutUseCase _requestPayout;

  Future<void> _onLoad(
      LoadEarningsEvent event, Emitter<EarningsState> emit) async {
    final period = event.period ?? 'last30days';
    emit(EarningsLoadingState(period: period));
    final result = await _getEarnings(GetCreatorEarningsParams(period: period));
    result.fold(
      (f) => emit(EarningsErrorState(failure: f, period: period)),
      (e) => emit(EarningsLoadedState(earnings: e, period: period)),
    );
  }

  Future<void> _onChangePeriod(
      ChangePeriodEvent event, Emitter<EarningsState> emit) async {
    emit(EarningsLoadingState(period: event.period));
    final result =
        await _getEarnings(GetCreatorEarningsParams(period: event.period));
    result.fold(
      (f) => emit(EarningsErrorState(failure: f, period: event.period)),
      (e) => emit(EarningsLoadedState(earnings: e, period: event.period)),
    );
  }

  Future<void> _onRequestPayout(
      RequestPayoutEvent event, Emitter<EarningsState> emit) async {
    if (state is! EarningsLoadedState) return;
    final current = state as EarningsLoadedState;
    emit(current.copyWith(isRequestingPayout: true));
    final result =
        await _requestPayout(RequestPayoutParams(amount: event.amount));
    result.fold(
      (f) => emit(current.copyWith(isRequestingPayout: false, payoutError: f)),
      (payout) => emit(current.copyWith(
        isRequestingPayout: false,
        payoutSuccess: true,
        recentPayout: payout,
      )),
    );
  }
}
