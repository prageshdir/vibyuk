import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_platform_analytics.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_analytics_usecases.dart';

part 'admin_analytics_event.dart';
part 'admin_analytics_state.dart';

class AdminAnalyticsBloc
    extends BaseBloc<AdminAnalyticsEvent, AdminAnalyticsState> {
  final GetPlatformAnalyticsUseCase _getAnalytics;

  AdminAnalyticsBloc({required GetPlatformAnalyticsUseCase getAnalytics})
      : _getAnalytics = getAnalytics,
        super(const AdminAnalyticsState()) {
    on<AdminAnalyticsFetch>(_onFetch);
    on<AdminAnalyticsPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onFetch(
    AdminAnalyticsFetch event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AdminAnalyticsLoadStatus.loading));
    final result = await _getAnalytics(
      GetAnalyticsParams(period: state.selectedPeriod),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminAnalyticsLoadStatus.error,
        errorMessage: failure.message,
      )),
      (analytics) => emit(state.copyWith(
        status: AdminAnalyticsLoadStatus.loaded,
        analytics: analytics,
      )),
    );
  }

  Future<void> _onPeriodChanged(
    AdminAnalyticsPeriodChanged event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    emit(state.copyWith(selectedPeriod: event.period));
    add(AdminAnalyticsFetch());
  }
}
