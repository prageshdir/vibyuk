import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/data/datasources/booking_engine_remote_data_source.dart';
import 'package:vibyuk/features/booking_engine/data/models/booking_contract_model.dart';
import 'package:vibyuk/features/booking_engine/data/models/booking_dispute_model.dart';
import 'package:vibyuk/features/booking_engine/data/models/booking_invoice_model.dart';
import 'package:vibyuk/features/booking_engine/data/models/booking_milestone_model.dart';
import 'package:vibyuk/features/booking_engine/data/models/booking_model.dart';
import 'package:vibyuk/features/booking_engine/data/models/booking_negotiation_message_model.dart';
import 'package:vibyuk/features/booking_engine/data/models/booking_reschedule_model.dart';
import 'package:vibyuk/features/booking_engine/data/models/booking_timeline_event_model.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_contract_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_dispute_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_invoice_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_milestone_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_negotiation_message_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_reschedule_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_timeline_event_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';

class BookingEngineRepositoryImpl extends BaseRepository
    implements BookingEngineRepository {
  BookingEngineRepositoryImpl(
      {required BookingEngineRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final BookingEngineRemoteDataSource _remote;

  PaginatedResult<T> _parsePaginated<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = (data['data'] as List<dynamic>? ?? [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedResult<T>(
      items: items,
      currentPage: meta['current_page'] as int? ?? 1,
      totalPages: meta['total_pages'] as int? ?? 1,
      totalItems: meta['total_items'] as int? ?? items.length,
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<BookingEntity>>> getBookings(
      {BookingStatus? status, int page = 1, int pageSize = 20}) =>
      safeCall(() async {
        final data = await _remote.getBookings(
            status: status?.name, page: page, pageSize: pageSize);
        return _parsePaginated(
            data, (j) => BookingModel.fromJson(j).toEntity());
      });

  @override
  Future<Either<Failure, BookingEntity>> getBookingDetail(
          String bookingId) =>
      safeCall(() async {
        final data = await _remote.getBookingDetail(bookingId);
        return BookingModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingEntity>> confirmBooking(String bookingId) =>
      safeCall(() async {
        final data = await _remote.confirmBooking(bookingId);
        return BookingModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingEntity>> cancelBooking(
          String bookingId, String reason) =>
      safeCall(() async {
        final data = await _remote.cancelBooking(bookingId, reason);
        return BookingModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, PaginatedResult<BookingEntity>>> getBookingHistory(
      {int page = 1, int pageSize = 20}) =>
      safeCall(() async {
        final data = await _remote.getBookingHistory(
            page: page, pageSize: pageSize);
        return _parsePaginated(
            data, (j) => BookingModel.fromJson(j).toEntity());
      });

  @override
  Future<Either<Failure, List<BookingMilestoneEntity>>> getMilestones(
          String bookingId) =>
      safeCall(() async {
        final list = await _remote.getMilestones(bookingId);
        return list
            .map((j) => BookingMilestoneModel.fromJson(j).toEntity())
            .toList();
      });

  @override
  Future<Either<Failure, BookingMilestoneEntity>> submitMilestone({
    required String bookingId,
    required String milestoneId,
    required String deliverableUrl,
    String? notes,
  }) =>
      safeCall(() async {
        final data = await _remote.submitMilestone(
          bookingId: bookingId,
          milestoneId: milestoneId,
          deliverableUrl: deliverableUrl,
          notes: notes,
        );
        return BookingMilestoneModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingMilestoneEntity>> approveMilestone(
          {required String bookingId, required String milestoneId}) =>
      safeCall(() async {
        final data = await _remote.approveMilestone(
            bookingId: bookingId, milestoneId: milestoneId);
        return BookingMilestoneModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingMilestoneEntity>> rejectMilestone({
    required String bookingId,
    required String milestoneId,
    required String reason,
  }) =>
      safeCall(() async {
        final data = await _remote.rejectMilestone(
          bookingId: bookingId,
          milestoneId: milestoneId,
          reason: reason,
        );
        return BookingMilestoneModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingContractEntity>> getContract(
          String bookingId) =>
      safeCall(() async {
        final data = await _remote.getContract(bookingId);
        return BookingContractModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingContractEntity>> signContract(
          String bookingId) =>
      safeCall(() async {
        final data = await _remote.signContract(bookingId);
        return BookingContractModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, List<BookingNegotiationMessageEntity>>>
      getNegotiationMessages(String bookingId) =>
          safeCall(() async {
            final list = await _remote.getNegotiationMessages(bookingId);
            return list
                .map((j) =>
                    BookingNegotiationMessageModel.fromJson(j).toEntity())
                .toList();
          });

  @override
  Future<Either<Failure, BookingNegotiationMessageEntity>>
      sendNegotiationMessage({
    required String bookingId,
    required NegotiationMessageType type,
    String? message,
    double? offeredPrice,
    String? currency,
  }) =>
          safeCall(() async {
            final data = await _remote.sendNegotiationMessage(
              bookingId: bookingId,
              type: type,
              message: message,
              offeredPrice: offeredPrice,
              currency: currency,
            );
            return BookingNegotiationMessageModel.fromJson(data).toEntity();
          });

  @override
  Future<Either<Failure, List<BookingTimelineEventEntity>>> getTimeline(
          String bookingId) =>
      safeCall(() async {
        final list = await _remote.getTimeline(bookingId);
        return list
            .map((j) => BookingTimelineEventModel.fromJson(j).toEntity())
            .toList();
      });

  @override
  Future<Either<Failure, BookingDisputeEntity?>> getDispute(
          String bookingId) =>
      safeCall(() async {
        final data = await _remote.getDispute(bookingId);
        if (data == null) return null;
        return BookingDisputeModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingDisputeEntity>> openDispute({
    required String bookingId,
    required DisputeReason reason,
    required String description,
  }) =>
      safeCall(() async {
        final data = await _remote.openDispute(
          bookingId: bookingId,
          reason: reason,
          description: description,
        );
        return BookingDisputeModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingDisputeEntity>> respondToDispute({
    required String disputeId,
    required String response,
  }) =>
      safeCall(() async {
        final data = await _remote.respondToDispute(
          disputeId: disputeId,
          response: response,
        );
        return BookingDisputeModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingRescheduleEntity>> requestReschedule({
    required String bookingId,
    required DateTime newDate,
    String? reason,
  }) =>
      safeCall(() async {
        final data = await _remote.requestReschedule(
          bookingId: bookingId,
          newDate: newDate,
          reason: reason,
        );
        return BookingRescheduleModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingRescheduleEntity>> respondToReschedule({
    required String rescheduleId,
    required bool accept,
    String? declineReason,
  }) =>
      safeCall(() async {
        final data = await _remote.respondToReschedule(
          rescheduleId: rescheduleId,
          accept: accept,
          declineReason: declineReason,
        );
        return BookingRescheduleModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingInvoiceEntity>> getInvoice(
          String bookingId) =>
      safeCall(() async {
        final data = await _remote.getInvoice(bookingId);
        return BookingInvoiceModel.fromJson(data).toEntity();
      });
}
