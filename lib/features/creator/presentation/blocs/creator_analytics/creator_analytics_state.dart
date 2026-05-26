part of 'creator_analytics_bloc.dart';

sealed class CreatorAnalyticsState extends Equatable {
  const CreatorAnalyticsState();
}

class CreatorAnalyticsInitialState extends CreatorAnalyticsState {
  const CreatorAnalyticsInitialState();
  @override
  List<Object?> get props => [];
}

class CreatorAnalyticsLoadingState extends CreatorAnalyticsState {
  const CreatorAnalyticsLoadingState({required this.period});
  final String period;
  @override
  List<Object?> get props => [period];
}

class CreatorAnalyticsLoadedState extends CreatorAnalyticsState {
  const CreatorAnalyticsLoadedState({
    required this.analytics,
    required this.period,
  });
  final CreatorAnalyticsEntity analytics;
  final String period;
  @override
  List<Object?> get props => [analytics, period];
}

class CreatorAnalyticsErrorState extends CreatorAnalyticsState {
  const CreatorAnalyticsErrorState({required this.failure, required this.period});
  final Failure failure;
  final String period;
  @override
  List<Object?> get props => [failure, period];
}
