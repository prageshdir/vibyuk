part of 'earnings_bloc.dart';

sealed class EarningsEvent extends Equatable {
  const EarningsEvent();
}

class LoadEarningsEvent extends EarningsEvent {
  const LoadEarningsEvent({this.period});
  final String? period;
  @override
  List<Object?> get props => [period];
}

class ChangePeriodEvent extends EarningsEvent {
  const ChangePeriodEvent({required this.period});
  final String period;
  @override
  List<Object?> get props => [period];
}

class RequestPayoutEvent extends EarningsEvent {
  const RequestPayoutEvent({required this.amount});
  final double amount;
  @override
  List<Object?> get props => [amount];
}
