import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/features/events/data/datasources/event_local_datasource.dart';
import 'package:vibyuk/features/events/data/datasources/event_remote_datasource.dart';
import 'package:vibyuk/features/events/data/repositories/event_repository_impl.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';
import 'package:vibyuk/features/events/domain/usecases/create_event_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/get_event_analytics_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/get_event_detail_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/get_events_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/get_my_tickets_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/get_ticket_detail_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/publish_event_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/purchase_tickets_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/request_refund_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/update_event_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/verify_ticket_usecase.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_dashboard/event_dashboard_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_detail/event_detail_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_form/event_form_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_list/event_list_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/my_tickets/my_tickets_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/ticket_purchase/ticket_purchase_bloc.dart';
import 'package:vibyuk/features/events/presentation/blocs/ticket_scanner/ticket_scanner_cubit.dart';

void registerEventModule(GetIt sl) {
  // ── Data sources ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<EventLocalDataSource>(
    () => EventLocalDataSourceImpl(
      dao: sl<AppDatabase>().eventsDao,
      cache: sl<CacheManager>(),
    ),
  );

  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(sl<Dio>()),
  );

  // ── Repository ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      local: sl<EventLocalDataSource>(),
      remote: sl<EventRemoteDataSource>(),
    ),
  );

  // ── Use cases ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetEventsUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => GetEventDetailUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateEventUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateEventUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => PublishEventUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => GetMyTicketsUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => GetTicketDetailUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => VerifyTicketUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => GetEventAnalyticsUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => PurchaseTicketsUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton(
    () => RequestRefundUseCase(sl<EventRepository>()),
  );

  // ── BLoCs (factory — screen-scoped) ──────────────────────────────────────────
  sl.registerFactory(
    () => EventListBloc(getEvents: sl<GetEventsUseCase>()),
  );
  sl.registerFactory(
    () => EventDetailBloc(
      getEventDetail: sl<GetEventDetailUseCase>(),
      publishEvent: sl<PublishEventUseCase>(),
    ),
  );
  sl.registerFactory(
    () => EventFormBloc(
      createEvent: sl<CreateEventUseCase>(),
      updateEvent: sl<UpdateEventUseCase>(),
    ),
  );
  sl.registerFactory(
    () => TicketPurchaseBloc(purchaseTickets: sl<PurchaseTicketsUseCase>()),
  );
  sl.registerFactory(
    () => MyTicketsBloc(getMyTickets: sl<GetMyTicketsUseCase>()),
  );
  sl.registerFactory(
    () => TicketScannerCubit(verifyTicket: sl<VerifyTicketUseCase>()),
  );
  sl.registerFactory(
    () => EventDashboardBloc(
      getEventDetail: sl<GetEventDetailUseCase>(),
      getAnalytics: sl<GetEventAnalyticsUseCase>(),
    ),
  );
}
