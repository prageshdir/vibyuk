import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/features/creator/data/datasources/creator_remote_data_source.dart';
import 'package:vibyuk/features/creator/data/repositories/creator_repository_impl.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';
import 'package:vibyuk/features/creator/domain/usecases/analytics/get_creator_analytics_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/availability/block_dates_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/availability/get_availability_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/availability/update_day_availability_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/availability/update_weekly_slots_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/bookings/get_booking_request_detail_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/bookings/get_booking_requests_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/bookings/respond_to_booking_request_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/campaigns/apply_to_campaign_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/campaigns/get_applications_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/campaigns/withdraw_application_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/bank_account/get_bank_account_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/bank_account/save_bank_account_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/earnings/get_creator_earnings_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/earnings/request_payout_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/kyc/get_kyc_status_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/kyc/submit_kyc_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/onboarding/complete_onboarding_step_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/add_portfolio_item_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/delete_portfolio_item_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/get_portfolio_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/reorder_portfolio_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/update_portfolio_item_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/pricing/create_pricing_package_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/pricing/delete_pricing_package_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/pricing/get_pricing_packages_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/pricing/update_pricing_package_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/profile/get_creator_profile_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/profile/get_public_creator_profile_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/profile/update_creator_profile_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/profile/upload_profile_image_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/reviews/get_reviews_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/reviews/respond_to_review_use_case.dart';
import 'package:vibyuk/features/creator/presentation/blocs/availability/availability_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/booking_requests/booking_requests_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/campaign_applications/campaign_applications_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_analytics/creator_analytics_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_profile/creator_profile_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/bank_account/bank_account_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/earnings/earnings_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/kyc/kyc_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/portfolio/portfolio_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/pricing/pricing_bloc.dart';
import 'package:vibyuk/features/creator/presentation/blocs/reviews/reviews_bloc.dart';

void registerCreatorModule(GetIt sl) {
  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<CreatorRemoteDataSource>(
      () => CreatorRemoteDataSourceImpl(sl<Dio>()));

  // ── Repository ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CreatorRepository>(
      () => CreatorRepositoryImpl(remoteDataSource: sl()));

  // ── Use Cases — Profile ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCreatorProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetPublicCreatorProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCreatorProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfileImageUseCase(sl()));
  sl.registerLazySingleton(() => UploadCoverImageUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingStepUseCase(sl()));

  // ── Use Cases — Portfolio ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetPortfolioUseCase(sl()));
  sl.registerLazySingleton(() => AddPortfolioItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePortfolioItemUseCase(sl()));
  sl.registerLazySingleton(() => DeletePortfolioItemUseCase(sl()));
  sl.registerLazySingleton(() => ReorderPortfolioUseCase(sl()));

  // ── Use Cases — Pricing ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetPricingPackagesUseCase(sl()));
  sl.registerLazySingleton(() => CreatePricingPackageUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePricingPackageUseCase(sl()));
  sl.registerLazySingleton(() => DeletePricingPackageUseCase(sl()));

  // ── Use Cases — Availability ──────────────────────────────────────────────
  sl.registerLazySingleton(() => GetAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDayAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWeeklySlotsUseCase(sl()));
  sl.registerLazySingleton(() => BlockDatesUseCase(sl()));

  // ── Use Cases — Analytics ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCreatorAnalyticsUseCase(sl()));

  // ── Use Cases — Earnings ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCreatorEarningsUseCase(sl()));
  sl.registerLazySingleton(() => RequestPayoutUseCase(sl()));

  // ── Use Cases — Booking Requests ──────────────────────────────────────────
  sl.registerLazySingleton(() => GetBookingRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingRequestDetailUseCase(sl()));
  sl.registerLazySingleton(() => RespondToBookingRequestUseCase(sl()));

  // ── Use Cases — Campaigns ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetApplicationsUseCase(sl()));
  sl.registerLazySingleton(() => ApplyToCampaignUseCase(sl()));
  sl.registerLazySingleton(() => WithdrawApplicationUseCase(sl()));

  // ── Use Cases — Reviews ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetReviewsUseCase(sl()));
  sl.registerLazySingleton(() => RespondToReviewUseCase(sl()));

  // ── Use Cases — Bank Account ─────────────────────────────────────────────
  sl.registerLazySingleton(() => GetBankAccountUseCase(sl()));
  sl.registerLazySingleton(() => SaveBankAccountUseCase(sl()));

  // ── Use Cases — KYC ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetKycStatusUseCase(sl()));
  sl.registerLazySingleton(() => SubmitKycUseCase(sl()));

  // ── BLoCs (factory — one per route) ──────────────────────────────────────
  sl.registerFactory(() => CreatorProfileBloc(
        getProfile: sl(),
        getPublicProfile: sl(),
        updateProfile: sl(),
        uploadProfileImage: sl(),
        uploadCoverImage: sl(),
        completeOnboardingStep: sl(),
      ));

  sl.registerFactory(() => PortfolioBloc(
        getPortfolio: sl(),
        addItem: sl(),
        updateItem: sl(),
        deleteItem: sl(),
        reorderPortfolio: sl(),
      ));

  sl.registerFactory(() => PricingBloc(
        getPackages: sl(),
        createPackage: sl(),
        updatePackage: sl(),
        deletePackage: sl(),
      ));

  sl.registerFactory(() => AvailabilityBloc(
        getAvailability: sl(),
        updateDay: sl(),
        updateSlots: sl(),
        blockDates: sl(),
      ));

  sl.registerFactory(
      () => CreatorAnalyticsBloc(getAnalytics: sl()));

  sl.registerFactory(() => EarningsBloc(
        getEarnings: sl(),
        requestPayout: sl(),
      ));

  sl.registerFactory(() => BookingRequestsBloc(
        getRequests: sl(),
        getDetail: sl(),
        respond: sl(),
      ));

  sl.registerFactory(() => CampaignApplicationsBloc(
        getApplications: sl(),
        apply: sl(),
        withdraw: sl(),
      ));

  sl.registerFactory(() => ReviewsBloc(
        getReviews: sl(),
        respondToReview: sl(),
      ));

  sl.registerFactory(() => KycBloc(
        getKycStatus: sl(),
        submitKyc: sl(),
      ));

  sl.registerFactory(() => BankAccountBloc(
        getBankAccount: sl(),
        saveBankAccount: sl(),
      ));
}
