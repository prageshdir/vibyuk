import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/api/api_client.dart';
import 'package:vibyuk/features/subscriptions/data/datasources/subscription_remote_data_source.dart';
import 'package:vibyuk/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:vibyuk/features/subscriptions/data/services/subscription_payment_service.dart';
import 'package:vibyuk/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:vibyuk/features/subscriptions/domain/usecases/cancel_subscription_use_case.dart';
import 'package:vibyuk/features/subscriptions/domain/usecases/get_subscription_use_case.dart';
import 'package:vibyuk/features/subscriptions/domain/usecases/upgrade_subscription_use_case.dart';
import 'package:vibyuk/features/subscriptions/domain/usecases/verify_subscription_payment_use_case.dart';
import 'package:vibyuk/features/subscriptions/presentation/bloc/subscription_bloc.dart';

void registerSubscriptionModule(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl<SubscriptionRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(
    () => GetSubscriptionUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton(
    () => UpgradeSubscriptionUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton(
    () => VerifySubscriptionPaymentUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton(
    () => CancelSubscriptionUseCase(sl<SubscriptionRepository>()),
  );

  // Payment service — factory so each screen gets a fresh Razorpay instance
  sl.registerFactory(() => SubscriptionPaymentService());

  // BLoC — singleton so subscription state is shared across the app
  sl.registerLazySingleton(
    () => SubscriptionBloc(
      getSubscription: sl<GetSubscriptionUseCase>(),
      upgradeSubscription: sl<UpgradeSubscriptionUseCase>(),
      verifyPayment: sl<VerifySubscriptionPaymentUseCase>(),
      cancelSubscription: sl<CancelSubscriptionUseCase>(),
    ),
  );

}
