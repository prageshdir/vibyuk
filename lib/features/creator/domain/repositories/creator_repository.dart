import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/campaign_application_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_analytics_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_earnings_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/bank_account_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/kyc_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/review_entity.dart';

abstract class CreatorRepository {
  // ── Profile ───────────────────────────────────────────────────────────────
  Future<Either<Failure, CreatorProfileEntity>> getProfile();
  Future<Either<Failure, CreatorProfileEntity>> getPublicProfile({required String creatorId});
  Future<Either<Failure, CreatorProfileEntity>> updateProfile({
    required String displayName,
    String? bio,
    String? location,
    String? website,
    List<String>? categories,
    List<String>? skills,
    List<String>? languagesSpoken,
    List<SocialLinkEntity>? socialLinks,
  });
  Future<Either<Failure, String>> uploadProfileImage({required String filePath});
  Future<Either<Failure, String>> uploadCoverImage({required String filePath});
  Future<Either<Failure, CreatorProfileEntity>> completeOnboardingStep({
    required OnboardingStep step,
  });

  // ── Portfolio ─────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResult<PortfolioItemEntity>>> getPortfolio({
    required int page,
    required int pageSize,
  });
  Future<Either<Failure, PortfolioItemEntity>> addPortfolioItem({
    required String title,
    String? description,
    required MediaType mediaType,
    required String filePath,
    required List<String> tags,
    required bool isFeatured,
  });
  Future<Either<Failure, PortfolioItemEntity>> updatePortfolioItem({
    required String itemId,
    required String title,
    String? description,
    required List<String> tags,
    required bool isFeatured,
  });
  Future<Either<Failure, void>> deletePortfolioItem({required String itemId});
  Future<Either<Failure, void>> reorderPortfolio({required List<String> orderedIds});

  // ── Pricing ───────────────────────────────────────────────────────────────
  Future<Either<Failure, List<PricingPackageEntity>>> getPricingPackages();
  Future<Either<Failure, PricingPackageEntity>> createPricingPackage({
    required PackageType packageType,
    required String title,
    required String description,
    required double price,
    required String currency,
    required int deliveryDays,
    required List<String> inclusions,
    required int revisions,
  });
  Future<Either<Failure, PricingPackageEntity>> updatePricingPackage({
    required String packageId,
    required String title,
    required String description,
    required double price,
    required String currency,
    required int deliveryDays,
    required List<String> inclusions,
    required int revisions,
    required bool isActive,
  });
  Future<Either<Failure, void>> deletePricingPackage({required String packageId});

  // ── Availability ──────────────────────────────────────────────────────────
  Future<Either<Failure, AvailabilityEntity>> getAvailability();
  Future<Either<Failure, AvailabilityEntity>> updateDayAvailability({
    required DateTime date,
    required DayAvailability status,
  });
  Future<Either<Failure, AvailabilityEntity>> updateWeeklySlots({
    required List<TimeSlotEntity> slots,
  });
  Future<Either<Failure, AvailabilityEntity>> blockDates({
    required List<DateTime> dates,
  });

  // ── Analytics ─────────────────────────────────────────────────────────────
  Future<Either<Failure, CreatorAnalyticsEntity>> getAnalytics({
    required String period,
  });

  // ── Earnings ──────────────────────────────────────────────────────────────
  Future<Either<Failure, CreatorEarningsEntity>> getEarnings({
    required String period,
  });
  Future<Either<Failure, PayoutEntity>> requestPayout({
    required double amount,
  });

  // ── Booking Requests ──────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResult<BookingRequestEntity>>> getBookingRequests({
    required int page,
    required int pageSize,
    BookingRequestStatus? statusFilter,
  });
  Future<Either<Failure, BookingRequestEntity>> getBookingRequestDetail({
    required String requestId,
  });
  Future<Either<Failure, BookingRequestEntity>> respondToBookingRequest({
    required String requestId,
    required bool accept,
    double? counterOfferPrice,
    String? counterOfferMessage,
  });

  // ── Campaign Applications ─────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResult<CampaignApplicationEntity>>> getApplications({
    required int page,
    required int pageSize,
    ApplicationStatus? statusFilter,
  });
  Future<Either<Failure, CampaignApplicationEntity>> applyToCampaign({
    required String campaignId,
    String? coverLetter,
    required List<String> portfolioItemIds,
    required double proposedRate,
    required String currency,
  });
  Future<Either<Failure, void>> withdrawApplication({required String applicationId});

  // ── Reviews ───────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResult<ReviewEntity>>> getReviews({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, ReviewEntity>> respondToReview({
    required String reviewId,
    required String response,
  });

  // ── Bank Account ──────────────────────────────────────────────────────────
  Future<Either<Failure, BankAccountEntity?>> getBankAccount();
  Future<Either<Failure, BankAccountEntity>> saveBankAccount({
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
  });

  // ── KYC ───────────────────────────────────────────────────────────────────
  Future<Either<Failure, KycEntity>> getKycStatus();
  Future<Either<Failure, KycEntity>> submitKyc({
    required KycDocumentType documentType,
    required String documentFrontPath,
    String? documentBackPath,
    required String selfiePath,
  });
}
