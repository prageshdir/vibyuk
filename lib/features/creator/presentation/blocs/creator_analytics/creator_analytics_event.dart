part of 'creator_analytics_bloc.dart';

sealed class CreatorAnalyticsEvent extends Equatable {
  const CreatorAnalyticsEvent();
}

class LoadCreatorAnalyticsEvent extends CreatorAnalyticsEvent {
  const LoadCreatorAnalyticsEvent({this.period});
  final String? period;
  @override
  List<Object?> get props => [period];
}

class ChangePeriodEvent extends CreatorAnalyticsEvent {
  const ChangePeriodEvent({required this.period});
  final String period;
  @override
  List<Object?> get props => [period];
}
