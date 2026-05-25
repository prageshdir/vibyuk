part of 'admin_analytics_bloc.dart';

enum AdminAnalyticsLoadStatus { initial, loading, loaded, error }

final class AdminAnalyticsState extends Equatable {
  final AdminAnalyticsLoadStatus status;
  final AdminPlatformAnalytics? analytics;
  final AdminAnalyticsPeriod selectedPeriod;
  final String? errorMessage;

  const AdminAnalyticsState({
    this.status = AdminAnalyticsLoadStatus.initial,
    this.analytics,
    this.selectedPeriod = AdminAnalyticsPeriod.last30Days,
    this.errorMessage,
  });

  AdminAnalyticsState copyWith({
    AdminAnalyticsLoadStatus? status,
    AdminPlatformAnalytics? analytics,
    AdminAnalyticsPeriod? selectedPeriod,
    String? errorMessage,
  }) {
    return AdminAnalyticsState(
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, analytics, selectedPeriod, errorMessage];
}
