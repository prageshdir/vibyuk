import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/features/booking_engine/data/datasources/booking_engine_remote_data_source.dart';
import 'package:vibyuk/features/booking_engine/data/repositories/booking_engine_repository_impl.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/cancel_booking_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/confirm_booking_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/get_booking_detail_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/get_booking_history_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/get_bookings_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/contract/get_contract_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/dispute/dispute_use_cases.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/invoice/get_invoice_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/milestones/approve_milestone_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/milestones/get_milestones_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/milestones/submit_milestone_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/negotiation/get_negotiation_messages_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/reschedule/reschedule_use_cases.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/timeline/get_booking_timeline_use_case.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/booking_detail/booking_detail_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/booking_engine/booking_engine_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/contract/contract_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/dispute/dispute_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/invoice/invoice_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/milestone/milestone_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/negotiation/negotiation_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/reschedule/reschedule_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/timeline/timeline_bloc.dart';

void registerBookingEngineModule(GetIt sl) {
  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<BookingEngineRemoteDataSource>(
      () => BookingEngineRemoteDataSourceImpl(sl<Dio>()));

  // ── Repository ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<BookingEngineRepository>(
      () => BookingEngineRepositoryImpl(remoteDataSource: sl()));

  // ── Use Cases — Bookings ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingDetailUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmBookingUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingHistoryUseCase(sl()));

  // ── Use Cases — Milestones ────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetMilestonesUseCase(sl()));
  sl.registerLazySingleton(() => SubmitMilestoneUseCase(sl()));
  sl.registerLazySingleton(() => ApproveMilestoneUseCase(sl()));
  sl.registerLazySingleton(() => RejectMilestoneUseCase(sl()));

  // ── Use Cases — Contract ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetContractUseCase(sl()));
  sl.registerLazySingleton(() => SignContractUseCase(sl()));

  // ── Use Cases — Negotiation ───────────────────────────────────────────────
  sl.registerLazySingleton(() => GetNegotiationMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendNegotiationMessageUseCase(sl()));

  // ── Use Cases — Timeline ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetBookingTimelineUseCase(sl()));

  // ── Use Cases — Dispute ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetDisputeUseCase(sl()));
  sl.registerLazySingleton(() => OpenDisputeUseCase(sl()));
  sl.registerLazySingleton(() => RespondToDisputeUseCase(sl()));

  // ── Use Cases — Reschedule ────────────────────────────────────────────────
  sl.registerLazySingleton(() => RequestRescheduleUseCase(sl()));
  sl.registerLazySingleton(() => RespondToRescheduleUseCase(sl()));

  // ── Use Cases — Invoice ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetInvoiceUseCase(sl()));

  // ── BLoCs (factory — one per route) ──────────────────────────────────────
  sl.registerFactory(() => BookingEngineBloc(getBookings: sl()));

  sl.registerFactory(() => BookingDetailBloc(
        getDetail: sl(),
        confirm: sl(),
        cancel: sl(),
      ));

  sl.registerFactory(() => MilestoneBloc(
        getMilestones: sl(),
        submitMilestone: sl(),
        approveMilestone: sl(),
        rejectMilestone: sl(),
      ));

  sl.registerFactory(() => ContractBloc(
        getContract: sl(),
        signContract: sl(),
      ));

  sl.registerFactory(() => NegotiationBloc(
        getMessages: sl(),
        sendMessage: sl(),
      ));

  sl.registerFactory(() => TimelineBloc(getTimeline: sl()));

  sl.registerFactory(() => DisputeBloc(
        getDispute: sl(),
        openDispute: sl(),
        respondToDispute: sl(),
      ));

  sl.registerFactory(() => RescheduleBloc(
        requestReschedule: sl(),
        respondToReschedule: sl(),
      ));

  sl.registerFactory(() => InvoiceBloc(getInvoice: sl()));
}
