part of 'analytics_bloc.dart';

sealed class AnalyticsState extends Equatable {
  const AnalyticsState();
}

class AnalyticsInitialState extends AnalyticsState {
  const AnalyticsInitialState();
  @override
  List<Object?> get props => [];
}

class AnalyticsLoadingState extends AnalyticsState {
  const AnalyticsLoadingState();
  @override
  List<Object?> get props => [];
}

class AnalyticsLoadedState extends AnalyticsState {
  const AnalyticsLoadedState({
    required this.dashboard,
    required this.selectedPeriod,
  });
  final AnalyticsDashboardEntity dashboard;
  final String selectedPeriod;
  @override
  List<Object?> get props => [dashboard, selectedPeriod];
}

class AnalyticsErrorState extends AnalyticsState {
  const AnalyticsErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
