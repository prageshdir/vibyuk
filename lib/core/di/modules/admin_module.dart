import 'package:get_it/get_it.dart';
import 'package:vibyuk/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:vibyuk/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:vibyuk/features/admin/domain/repositories/admin_repository.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_analytics_usecases.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_dispute_usecases.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_moderation_usecases.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_reports_usecases.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_verification_usecases.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_analytics/admin_analytics_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_disputes/admin_disputes_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_moderation/admin_moderation_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_reports/admin_reports_bloc.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_verification/admin_verification_bloc.dart';

void registerAdminModule(GetIt sl) {
  // Data source
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl()),
  );

  // Use cases — Moderation
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserDetailUseCase(sl()));
  sl.registerLazySingleton(() => ModerateUserUseCase(sl()));

  // Use cases — Disputes
  sl.registerLazySingleton(() => GetDisputesUseCase(sl()));
  sl.registerLazySingleton(() => GetDisputeDetailUseCase(sl()));
  sl.registerLazySingleton(() => AssignDisputeUseCase(sl()));
  sl.registerLazySingleton(() => ResolveDisputeUseCase(sl()));
  sl.registerLazySingleton(() => AddDisputeMessageUseCase(sl()));

  // Use cases — Verifications
  sl.registerLazySingleton(() => GetVerificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetVerificationDetailUseCase(sl()));
  sl.registerLazySingleton(() => ReviewVerificationUseCase(sl()));

  // Use cases — Analytics
  sl.registerLazySingleton(() => GetPlatformAnalyticsUseCase(sl()));

  // Use cases — Reports
  sl.registerLazySingleton(() => GetReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetReportDetailUseCase(sl()));
  sl.registerLazySingleton(() => HandleReportUseCase(sl()));

  // BLoCs (factory — new instance per route)
  sl.registerFactory(
    () => AdminModerationBloc(
      getUsers: sl(),
      getUserDetail: sl(),
      moderateUser: sl(),
    ),
  );
  sl.registerFactory(
    () => AdminDisputesBloc(
      getDisputes: sl(),
      getDisputeDetail: sl(),
      assignDispute: sl(),
      resolveDispute: sl(),
      addMessage: sl(),
    ),
  );
  sl.registerFactory(
    () => AdminVerificationBloc(
      getVerifications: sl(),
      getVerificationDetail: sl(),
      reviewVerification: sl(),
    ),
  );
  sl.registerFactory(
    () => AdminAnalyticsBloc(getAnalytics: sl()),
  );
  sl.registerFactory(
    () => AdminReportsBloc(
      getReports: sl(),
      getReportDetail: sl(),
      handleReport: sl(),
    ),
  );
}
