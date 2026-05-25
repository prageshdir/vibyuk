part of 'reschedule_bloc.dart';

sealed class RescheduleEvent extends Equatable {
  const RescheduleEvent();
}

class RequestRescheduleSubmitEvent extends RescheduleEvent {
  const RequestRescheduleSubmitEvent({
    required this.bookingId,
    required this.newDate,
    this.reason,
  });
  final String bookingId;
  final DateTime newDate;
  final String? reason;
  @override
  List<Object?> get props => [bookingId, newDate, reason];
}

class RespondToRescheduleSubmitEvent extends RescheduleEvent {
  const RespondToRescheduleSubmitEvent({
    required this.rescheduleId,
    required this.accept,
    this.declineReason,
  });
  final String rescheduleId;
  final bool accept;
  final String? declineReason;
  @override
  List<Object?> get props => [rescheduleId, accept, declineReason];
}
