import 'package:equatable/equatable.dart';

abstract class AiInsightsEvent extends Equatable {
  const AiInsightsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInsights extends AiInsightsEvent {
  const LoadInsights();
}

class DismissInsight extends AiInsightsEvent {
  final String insightId;

  const DismissInsight({required this.insightId});

  @override
  List<Object?> get props => [insightId];
}

class RefreshInsights extends AiInsightsEvent {
  const RefreshInsights();
}
