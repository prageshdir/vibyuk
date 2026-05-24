part of 'earnings_bloc.dart';

sealed class EarningsState extends Equatable {
  const EarningsState();
}

class EarningsInitialState extends EarningsState {
  const EarningsInitialState();
  @override
  List<Object?> get props => [];
}

class EarningsLoadingState extends EarningsState {
  const EarningsLoadingState({required this.period});
  final String period;
  @override
  List<Object?> get props => [period];
}

class EarningsLoadedState extends EarningsState {
  const EarningsLoadedState({
    required this.earnings,
    required this.period,
    this.isRequestingPayout = false,
    this.payoutError,
    this.payoutSuccess = false,
    this.recentPayout,
  });
  final CreatorEarningsEntity earnings;
  final String period;
  final bool isRequestingPayout;
  final Failure? payoutError;
  final bool payoutSuccess;
  final PayoutEntity? recentPayout;

  EarningsLoadedState copyWith({
    CreatorEarningsEntity? earnings,
    String? period,
    bool? isRequestingPayout,
    Failure? payoutError,
    bool? payoutSuccess,
    PayoutEntity? recentPayout,
  }) =>
      EarningsLoadedState(
        earnings: earnings ?? this.earnings,
        period: period ?? this.period,
        isRequestingPayout: isRequestingPayout ?? false,
        payoutError: payoutError,
        payoutSuccess: payoutSuccess ?? false,
        recentPayout: recentPayout ?? this.recentPayout,
      );

  @override
  List<Object?> get props =>
      [earnings, period, isRequestingPayout, payoutError, payoutSuccess, recentPayout];
}

class EarningsErrorState extends EarningsState {
  const EarningsErrorState({required this.failure, required this.period});
  final Failure failure;
  final String period;
  @override
  List<Object?> get props => [failure, period];
}
