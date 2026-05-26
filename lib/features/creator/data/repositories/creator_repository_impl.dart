import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/creator/data/datasources/creator_remote_data_source.dart';
import 'package:vibyuk/features/creator/data/models/availability_model.dart';
import 'package:vibyuk/features/creator/data/models/booking_request_model.dart';
import 'package:vibyuk/features/creator/data/models/campaign_application_model.dart';
import 'package:vibyuk/features/creator/data/models/creator_analytics_model.dart';
import 'package:vibyuk/features/creator/data/models/creator_earnings_model.dart';
import 'package:vibyuk/features/creator/data/models/creator_profile_model.dart';
import 'package:vibyuk/features/creator/data/models/kyc_model.dart';
import 'package:vibyuk/features/creator/data/models/portfolio_item_model.dart';
import 'package:vibyuk/features/creator/data/models/pricing_package_model.dart';
import 'package:vibyuk/features/creator/data/models/review_model.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/campaign_application_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_analytics_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_earnings_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/kyc_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
import 'package:vibyuk/features/creator/domain/entities/review_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class CreatorRepositoryImpl extends BaseRepository implements CreatorRepository {
  CreatorRepositoryImpl({required CreatorRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final CreatorRemoteDataSource _remote;

  PaginatedResult<T> _parsePaginated<T>(
      Map<String, dynamic> data, T Function(Map<String, dynamic>) fromJson) {
    final raw = data['items'] as List? ?? data['data'] as List? ?? [];
    final items = raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    return PaginatedResult<T>(
      items: items,
      currentPage: data['current_page'] as int? ?? data['page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
      totalItems: data['total_items'] as int? ?? items.length,
    );
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, CreatorProfileEntity>> getProfile() =>
      safeCall(() async {
        final data = await _remote.getProfile();
        return CreatorProfileModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, CreatorProfileEntity>> getPublicProfile(
          {required String creatorId}) =>
      safeCall(() async {
        final data = await _remote.getPublicProfile(creatorId);
        return CreatorProfileModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, CreatorProfileEntity>> updateProfile({
    required String displayName,
    String? bio,
    String? location,
    String? website,
    List<String>? categories,
    List<String>? skills,
    List<SocialLinkEntity>? socialLinks,
  }) =>
      safeCall(() async {
        final body = <String, dynamic>{
          'display_name': displayName,
          if (bio != null) 'bio': bio,
          if (location != null) 'location': location,
          if (website != null) 'website': website,
          if (categories != null) 'categories': categories,
          if (skills != null) 'skills': skills,
          if (socialLinks != null)
            'social_links': socialLinks
                .map((l) => {
                      'platform': l.platform,
                      'url': l.url,
                      if (l.followerCount != null) 'follower_count': l.followerCount,
                    })
                .toList(),
        };
        final data = await _remote.updateProfile(body);
        return CreatorProfileModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, String>> uploadProfileImage({required String filePath}) =>
      safeCall(() async {
        final data = await _remote.uploadProfileImage(filePath);
        return data['url'] as String;
      });

  @override
  Future<Either<Failure, String>> uploadCoverImage({required String filePath}) =>
      safeCall(() async {
        final data = await _remote.uploadCoverImage(filePath);
        return data['url'] as String;
      });

  @override
  Future<Either<Failure, CreatorProfileEntity>> completeOnboardingStep(
          {required OnboardingStep step}) =>
      safeCall(() async {
        final data = await _remote.completeOnboardingStep(step.name);
        return CreatorProfileModel.fromJson(data).toEntity();
      });

  // ── Portfolio ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<PortfolioItemEntity>>> getPortfolio({
    required int page,
    required int pageSize,
  }) =>
      safeCall(() async {
        final data = await _remote.getPortfolio(page, pageSize);
        return _parsePaginated(
          data,
          (e) => PortfolioItemModel.fromJson(e).toEntity(),
        );
      });

  @override
  Future<Either<Failure, PortfolioItemEntity>> addPortfolioItem({
    required String title,
    String? description,
    required MediaType mediaType,
    required String filePath,
    required List<String> tags,
    required bool isFeatured,
  }) =>
      safeCall(() async {
        final form = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath),
          'title': title,
          'media_type': mediaType.name,
          'tags': tags.join(','),
          'is_featured': isFeatured.toString(),
          if (description != null) 'description': description,
        });
        final data = await _remote.addPortfolioItem(form);
        return PortfolioItemModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, PortfolioItemEntity>> updatePortfolioItem({
    required String itemId,
    required String title,
    String? description,
    required List<String> tags,
    required bool isFeatured,
  }) =>
      safeCall(() async {
        final body = <String, dynamic>{
          'title': title,
          'tags': tags,
          'is_featured': isFeatured,
          if (description != null) 'description': description,
        };
        final data = await _remote.updatePortfolioItem(itemId, body);
        return PortfolioItemModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, void>> deletePortfolioItem({required String itemId}) =>
      safeCall(() => _remote.deletePortfolioItem(itemId));

  @override
  Future<Either<Failure, void>> reorderPortfolio({required List<String> orderedIds}) =>
      safeCall(() => _remote.reorderPortfolio(orderedIds));

  // ── Pricing ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<PricingPackageEntity>>> getPricingPackages() =>
      safeCall(() async {
        final list = await _remote.getPricingPackages();
        return list
            .map((e) =>
                PricingPackageModel.fromJson(e as Map<String, dynamic>).toEntity())
            .toList();
      });

  @override
  Future<Either<Failure, PricingPackageEntity>> createPricingPackage({
    required PackageType packageType,
    required String title,
    required String description,
    required double price,
    required String currency,
    required int deliveryDays,
    required List<String> inclusions,
    required int revisions,
  }) =>
      safeCall(() async {
        final body = {
          'package_type': packageType.name,
          'title': title,
          'description': description,
          'price': price,
          'currency': currency,
          'delivery_days': deliveryDays,
          'inclusions': inclusions,
          'revisions': revisions,
        };
        final data = await _remote.createPricingPackage(body);
        return PricingPackageModel.fromJson(data).toEntity();
      });

  @override
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
  }) =>
      safeCall(() async {
        final body = {
          'title': title,
          'description': description,
          'price': price,
          'currency': currency,
          'delivery_days': deliveryDays,
          'inclusions': inclusions,
          'revisions': revisions,
          'is_active': isActive,
        };
        final data = await _remote.updatePricingPackage(packageId, body);
        return PricingPackageModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, void>> deletePricingPackage({required String packageId}) =>
      safeCall(() => _remote.deletePricingPackage(packageId));

  // ── Availability ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AvailabilityEntity>> getAvailability() =>
      safeCall(() async {
        final data = await _remote.getAvailability();
        return AvailabilityModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, AvailabilityEntity>> updateDayAvailability({
    required DateTime date,
    required DayAvailability status,
  }) =>
      safeCall(() async {
        final body = {
          'date': date.toIso8601String().split('T').first,
          'status': status.name,
        };
        final data = await _remote.updateDayAvailability(body);
        return AvailabilityModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, AvailabilityEntity>> updateWeeklySlots({
    required List<TimeSlotEntity> slots,
  }) =>
      safeCall(() async {
        final slotsJson = slots
            .map((s) => {
                  'weekday': s.weekday,
                  'start_hour': s.startHour,
                  'start_minute': s.startMinute,
                  'end_hour': s.endHour,
                  'end_minute': s.endMinute,
                })
            .toList();
        final data = await _remote.updateWeeklySlots(slotsJson);
        return AvailabilityModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, AvailabilityEntity>> blockDates({
    required List<DateTime> dates,
  }) =>
      safeCall(() async {
        final dateStrs =
            dates.map((d) => d.toIso8601String().split('T').first).toList();
        final data = await _remote.blockDates(dateStrs);
        return AvailabilityModel.fromJson(data).toEntity();
      });

  // ── Analytics ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, CreatorAnalyticsEntity>> getAnalytics({
    required String period,
  }) =>
      safeCall(() async {
        final data = await _remote.getAnalytics(period);
        return CreatorAnalyticsModel.fromJson(data).toEntity();
      });

  // ── Earnings ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, CreatorEarningsEntity>> getEarnings({
    required String period,
  }) =>
      safeCall(() async {
        final data = await _remote.getEarnings(period);
        return CreatorEarningsModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, PayoutEntity>> requestPayout({required double amount}) =>
      safeCall(() async {
        final data = await _remote.requestPayout(amount);
        return PayoutModel.fromJson(data).toEntity();
      });

  // ── Booking Requests ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<BookingRequestEntity>>> getBookingRequests({
    required int page,
    required int pageSize,
    BookingRequestStatus? statusFilter,
  }) =>
      safeCall(() async {
        final data = await _remote.getBookingRequests(
            page, pageSize, statusFilter?.name);
        return _parsePaginated(
          data,
          (e) => BookingRequestModel.fromJson(e).toEntity(),
        );
      });

  @override
  Future<Either<Failure, BookingRequestEntity>> getBookingRequestDetail({
    required String requestId,
  }) =>
      safeCall(() async {
        final data = await _remote.getBookingRequestDetail(requestId);
        return BookingRequestModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingRequestEntity>> respondToBookingRequest({
    required String requestId,
    required bool accept,
    double? counterOfferPrice,
    String? counterOfferMessage,
  }) =>
      safeCall(() async {
        final body = <String, dynamic>{
          'accept': accept,
          if (counterOfferPrice != null) 'counter_offer_price': counterOfferPrice,
          if (counterOfferMessage != null) 'counter_offer_message': counterOfferMessage,
        };
        final data = await _remote.respondToBookingRequest(requestId, body);
        return BookingRequestModel.fromJson(data).toEntity();
      });

  // ── Campaign Applications ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<CampaignApplicationEntity>>> getApplications({
    required int page,
    required int pageSize,
    ApplicationStatus? statusFilter,
  }) =>
      safeCall(() async {
        final data = await _remote.getApplications(
            page, pageSize, statusFilter?.name);
        return _parsePaginated(
          data,
          (e) => CampaignApplicationModel.fromJson(e).toEntity(),
        );
      });

  @override
  Future<Either<Failure, CampaignApplicationEntity>> applyToCampaign({
    required String campaignId,
    String? coverLetter,
    required List<String> portfolioItemIds,
    required double proposedRate,
    required String currency,
  }) =>
      safeCall(() async {
        final body = <String, dynamic>{
          'portfolio_item_ids': portfolioItemIds,
          'proposed_rate': proposedRate,
          'currency': currency,
          if (coverLetter != null) 'cover_letter': coverLetter,
        };
        final data = await _remote.applyToCampaign(campaignId, body);
        return CampaignApplicationModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, void>> withdrawApplication({required String applicationId}) =>
      safeCall(() => _remote.withdrawApplication(applicationId));

  // ── Reviews ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<ReviewEntity>>> getReviews({
    required int page,
    required int pageSize,
  }) =>
      safeCall(() async {
        final data = await _remote.getReviews(page, pageSize);
        return _parsePaginated(
          data,
          (e) => ReviewModel.fromJson(e).toEntity(),
        );
      });

  // ── KYC ────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, KycEntity>> getKycStatus() =>
      safeCall(() async {
        final data = await _remote.getKycStatus();
        return KycModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, KycEntity>> submitKyc({
    required KycDocumentType documentType,
    required String documentFrontPath,
    String? documentBackPath,
    required String selfiePath,
  }) =>
      safeCall(() async {
        final form = FormData.fromMap({
          'document_type': documentType.name,
          'document_front': await MultipartFile.fromFile(documentFrontPath),
          if (documentBackPath != null)
            'document_back': await MultipartFile.fromFile(documentBackPath),
          'selfie': await MultipartFile.fromFile(selfiePath),
        });
        final data = await _remote.submitKyc(form);
        return KycModel.fromJson(data).toEntity();
      });
}
