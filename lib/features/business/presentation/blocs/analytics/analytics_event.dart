part of 'analytics_bloc.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
}

class LoadAnalyticsDashboardEvent extends AnalyticsEvent {
  const LoadAnalyticsDashboardEvent({this.period = '30d'});
  final String period;
  @override
  List<Object?> get props => [period];
}

class ChangePeriodEvent extends AnalyticsEvent {
  const ChangePeriodEvent({required this.period});
  final String period;
  @override
  List<Object?> get props => [period];
}
