part of 'admin_analytics_bloc.dart';

sealed class AdminAnalyticsEvent {}

final class AdminAnalyticsFetch extends AdminAnalyticsEvent {}

final class AdminAnalyticsPeriodChanged extends AdminAnalyticsEvent {
  final AdminAnalyticsPeriod period;
  AdminAnalyticsPeriodChanged(this.period);
}
