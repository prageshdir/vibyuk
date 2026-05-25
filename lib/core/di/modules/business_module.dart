import 'package:get_it/get_it.dart';
import 'package:vibyuk/features/business/data/datasources/analytics_remote_data_source.dart';
import 'package:vibyuk/features/business/data/datasources/booking_remote_data_source.dart';
import 'package:vibyuk/features/business/data/datasources/campaign_remote_data_source.dart';
import 'package:vibyuk/features/business/data/datasources/discovery_local_data_source.dart';
import 'package:vibyuk/features/business/data/datasources/discovery_remote_data_source.dart';
import 'package:vibyuk/features/business/data/datasources/notifications_remote_data_source.dart';
import 'package:vibyuk/features/business/data/datasources/payment_remote_data_source.dart';
import 'package:vibyuk/features/business/data/datasources/team_remote_data_source.dart';
import 'package:vibyuk/features/business/data/services/payment_gateway_service.dart';
import 'package:vibyuk/features/business/data/repositories/analytics_repository_impl.dart';
import 'package:vibyuk/features/business/data/repositories/booking_repository_impl.dart';
import 'package:vibyuk/features/business/data/repositories/campaign_repository_impl.dart';
import 'package:vibyuk/features/business/data/repositories/discovery_repository_impl.dart';
import 'package:vibyuk/features/business/data/repositories/notifications_repository_impl.dart';
import 'package:vibyuk/features/business/data/repositories/payment_repository_impl.dart';
import 'package:vibyuk/features/business/data/repositories/team_repository_impl.dart';
import 'package:vibyuk/features/business/domain/repositories/analytics_repository.dart';
import 'package:vibyuk/features/business/domain/repositories/booking_repository.dart';
import 'package:vibyuk/features/business/domain/repositories/campaign_repository.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';
import 'package:vibyuk/features/business/domain/repositories/notifications_repository.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';
import 'package:vibyuk/features/business/domain/repositories/team_repository.dart';
import 'package:vibyuk/features/business/domain/usecases/analytics/get_analytics_dashboard_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/booking/cancel_booking_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/booking/get_booking_detail_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/booking/get_bookings_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/booking/update_booking_status_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/create_campaign_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/delete_campaign_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/get_campaign_detail_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/get_campaigns_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/publish_campaign_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/update_campaign_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/get_featured_creators_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/get_recent_searches_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/get_saved_creators_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/save_creator_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/save_recent_search_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/search_creators_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/discovery/unsave_creator_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/notifications/get_notifications_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/notifications/mark_all_notifications_read_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/notifications/mark_notification_read_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_escrow_details_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_invoice_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_payment_analytics_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_payment_detail_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_payments_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_transactions_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/initiate_payment_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/release_escrow_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/request_refund_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/verify_payment_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/team/get_team_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/team/invite_team_member_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/team/remove_team_member_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/team/update_team_member_role_use_case.dart';
import 'package:vibyuk/features/business/presentation/blocs/analytics/analytics_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/booking/booking_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/campaign/campaign_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/discovery/discovery_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/escrow/escrow_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/invoice/invoice_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/payment/payment_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/payment_analytics/payment_analytics_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/team/team_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/transaction/transaction_bloc.dart';

void registerBusinessModule(GetIt sl) {
  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<DiscoveryRemoteDataSource>(
      () => DiscoveryRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<DiscoveryLocalDataSource>(
      () => DiscoveryLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<CampaignRemoteDataSource>(
      () => CampaignRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<BookingRemoteDataSource>(
      () => BookingRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TeamRemoteDataSource>(
      () => TeamRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
      () => AnalyticsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<PaymentRemoteDataSource>(
      () => PaymentRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSourceImpl(sl()));

  // ── Data Services ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentGatewayService>(() => PaymentGatewayService());

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<CampaignRepository>(
    () => CampaignRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Discovery Use Cases ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => SearchCreatorsUseCase(sl()));
  sl.registerLazySingleton(() => GetFeaturedCreatorsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentSearchesUseCase(sl()));
  sl.registerLazySingleton(() => SaveRecentSearchUseCase(sl()));
  sl.registerLazySingleton(() => SaveCreatorUseCase(sl()));
  sl.registerLazySingleton(() => UnsaveCreatorUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedCreatorsUseCase(sl()));

  // ── Campaign Use Cases ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCampaignsUseCase(sl()));
  sl.registerLazySingleton(() => GetCampaignDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreateCampaignUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCampaignUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCampaignUseCase(sl()));
  sl.registerLazySingleton(() => PublishCampaignUseCase(sl()));

  // ── Booking Use Cases ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingDetailUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBookingStatusUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));

  // ── Team Use Cases ────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetTeamUseCase(sl()));
  sl.registerLazySingleton(() => InviteTeamMemberUseCase(sl()));
  sl.registerLazySingleton(() => RemoveTeamMemberUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTeamMemberRoleUseCase(sl()));

  // ── Analytics & Payment & Notifications Use Cases ─────────────────────────
  sl.registerLazySingleton(() => GetAnalyticsDashboardUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentDetailUseCase(sl()));
  sl.registerLazySingleton(() => InitiatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetEscrowDetailsUseCase(sl()));
  sl.registerLazySingleton(() => ReleaseEscrowUseCase(sl()));
  sl.registerLazySingleton(() => RequestRefundUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => GetInvoicePdfUrlUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));

  // ── BLoCs (factories — one instance per route) ────────────────────────────
  sl.registerFactory<DiscoveryBloc>(
    () => DiscoveryBloc(
      searchCreators: sl(),
      getFeaturedCreators: sl(),
      getRecentSearches: sl(),
      saveRecentSearch: sl(),
      saveCreator: sl(),
      unsaveCreator: sl(),
      getSavedCreators: sl(),
    ),
  );
  sl.registerFactory<CampaignBloc>(
    () => CampaignBloc(
      getCampaigns: sl(),
      getCampaignDetail: sl(),
      createCampaign: sl(),
      updateCampaign: sl(),
      deleteCampaign: sl(),
      publishCampaign: sl(),
    ),
  );
  sl.registerFactory<BookingBloc>(
    () => BookingBloc(
      getBookings: sl(),
      getBookingDetail: sl(),
      updateBookingStatus: sl(),
      cancelBooking: sl(),
    ),
  );
  sl.registerFactory<TeamBloc>(
    () => TeamBloc(
      getTeam: sl(),
      inviteTeamMember: sl(),
      removeTeamMember: sl(),
      updateTeamMemberRole: sl(),
    ),
  );
  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(getAnalyticsDashboard: sl()),
  );
  sl.registerFactory<PaymentBloc>(
    () => PaymentBloc(
      getPayments: sl(),
      initiatePayment: sl(),
      verifyPayment: sl(),
    ),
  );
  sl.registerFactory<EscrowBloc>(
    () => EscrowBloc(
      getEscrowDetails: sl(),
      releaseEscrow: sl(),
      requestRefund: sl(),
    ),
  );
  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(getTransactions: sl()),
  );
  sl.registerFactory<InvoiceBloc>(
    () => InvoiceBloc(
      getInvoice: sl(),
      getInvoicePdfUrl: sl(),
    ),
  );
  sl.registerFactory<NotificationsBloc>(
    () => NotificationsBloc(
      getNotifications: sl(),
      markNotificationRead: sl(),
      markAllNotificationsRead: sl(),
    ),
  );
  sl.registerFactory<PaymentAnalyticsBloc>(
    () => PaymentAnalyticsBloc(getAnalytics: sl()),
  );
}
