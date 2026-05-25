import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_insight.dart';

enum AiInsightsStatus { initial, loading, success, failure }

class AiInsightsState extends Equatable {
  final AiInsightsStatus status;
  final List<AiInsight> insights;
  final Set<String> dismissingIds;
  final Failure? failure;

  const AiInsightsState({
    this.status = AiInsightsStatus.initial,
    this.insights = const [],
    this.dismissingIds = const {},
    this.failure,
  });

  bool get isLoading => status == AiInsightsStatus.loading;
  bool get hasData => insights.isNotEmpty;
  bool get hasError => status == AiInsightsStatus.failure;

  List<AiInsight> get criticalInsights =>
      insights.where((i) => i.priority == InsightPriority.critical).toList();
  List<AiInsight> get highInsights =>
      insights.where((i) => i.priority == InsightPriority.high).toList();
  List<AiInsight> get opportunityInsights =>
      insights.where((i) => i.type == InsightType.opportunity).toList();

  AiInsightsState copyWith({
    AiInsightsStatus? status,
    List<AiInsight>? insights,
    Set<String>? dismissingIds,
    Failure? failure,
  }) {
    return AiInsightsState(
      status: status ?? this.status,
      insights: insights ?? this.insights,
      dismissingIds: dismissingIds ?? this.dismissingIds,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, insights, dismissingIds, failure];
}
