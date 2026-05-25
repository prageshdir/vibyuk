import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';

enum AiAnalyticsStatus { initial, loading, success, failure }

class AiAnalyticsState extends Equatable {
  final AiAnalyticsStatus status;
  final AiAnalytics? analytics;
  final AnalyticsPeriod selectedPeriod;
  final Failure? failure;

  const AiAnalyticsState({
    this.status = AiAnalyticsStatus.initial,
    this.analytics,
    this.selectedPeriod = AnalyticsPeriod.last30Days,
    this.failure,
  });

  bool get isLoading => status == AiAnalyticsStatus.loading;
  bool get hasData => analytics != null;
  bool get hasError => status == AiAnalyticsStatus.failure;

  AiAnalyticsState copyWith({
    AiAnalyticsStatus? status,
    AiAnalytics? analytics,
    AnalyticsPeriod? selectedPeriod,
    Failure? failure,
  }) {
    return AiAnalyticsState(
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, analytics, selectedPeriod, failure];
}
