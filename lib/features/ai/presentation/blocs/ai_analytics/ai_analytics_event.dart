import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';

abstract class AiAnalyticsEvent extends Equatable {
  const AiAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AiAnalyticsEvent {
  final AnalyticsPeriod period;

  const LoadAnalytics({this.period = AnalyticsPeriod.last30Days});

  @override
  List<Object?> get props => [period];
}

class ChangePeriod extends AiAnalyticsEvent {
  final AnalyticsPeriod period;

  const ChangePeriod({required this.period});

  @override
  List<Object?> get props => [period];
}

class RefreshAnalytics extends AiAnalyticsEvent {
  const RefreshAnalytics();
}
