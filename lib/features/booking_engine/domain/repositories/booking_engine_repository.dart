import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_contract_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_dispute_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_invoice_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_milestone_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_negotiation_message_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_reschedule_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_timeline_event_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';

abstract interface class BookingEngineRepository {
  // Bookings
  Future<Either<Failure, PaginatedResult<BookingEntity>>> getBookings({
    BookingStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, BookingEntity>> getBookingDetail(String bookingId);

  Future<Either<Failure, BookingEntity>> confirmBooking(String bookingId);

  Future<Either<Failure, BookingEntity>> cancelBooking(
      String bookingId, String reason);

  Future<Either<Failure, PaginatedResult<BookingEntity>>> getBookingHistory({
    int page = 1,
    int pageSize = 20,
  });

  // Milestones
  Future<Either<Failure, List<BookingMilestoneEntity>>> getMilestones(
      String bookingId);

  Future<Either<Failure, BookingMilestoneEntity>> submitMilestone({
    required String bookingId,
    required String milestoneId,
    required String deliverableUrl,
    String? notes,
  });

  Future<Either<Failure, BookingMilestoneEntity>> approveMilestone({
    required String bookingId,
    required String milestoneId,
  });

  Future<Either<Failure, BookingMilestoneEntity>> rejectMilestone({
    required String bookingId,
    required String milestoneId,
    required String reason,
  });

  // Contract
  Future<Either<Failure, BookingContractEntity>> getContract(String bookingId);

  Future<Either<Failure, BookingContractEntity>> signContract(String bookingId);

  // Negotiation
  Future<Either<Failure, List<BookingNegotiationMessageEntity>>>
      getNegotiationMessages(String bookingId);

  Future<Either<Failure, BookingNegotiationMessageEntity>>
      sendNegotiationMessage({
    required String bookingId,
    required NegotiationMessageType type,
    String? message,
    double? offeredPrice,
    String? currency,
  });

  // Timeline
  Future<Either<Failure, List<BookingTimelineEventEntity>>> getTimeline(
      String bookingId);

  // Dispute
  Future<Either<Failure, BookingDisputeEntity?>> getDispute(String bookingId);

  Future<Either<Failure, BookingDisputeEntity>> openDispute({
    required String bookingId,
    required DisputeReason reason,
    required String description,
  });

  Future<Either<Failure, BookingDisputeEntity>> respondToDispute({
    required String disputeId,
    required String response,
  });

  // Reschedule
  Future<Either<Failure, BookingRescheduleEntity>> requestReschedule({
    required String bookingId,
    required DateTime newDate,
    String? reason,
  });

  Future<Either<Failure, BookingRescheduleEntity>> respondToReschedule({
    required String rescheduleId,
    required bool accept,
    String? declineReason,
  });

  // Invoice
  Future<Either<Failure, BookingInvoiceEntity>> getInvoice(String bookingId);
}
