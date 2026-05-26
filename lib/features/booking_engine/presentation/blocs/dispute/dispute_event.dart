part of 'dispute_bloc.dart';

sealed class DisputeEvent extends Equatable {
  const DisputeEvent();
}

class LoadDisputeEvent extends DisputeEvent {
  const LoadDisputeEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class OpenDisputeSubmitEvent extends DisputeEvent {
  const OpenDisputeSubmitEvent({
    required this.bookingId,
    required this.reason,
    required this.description,
  });
  final String bookingId;
  final DisputeReason reason;
  final String description;
  @override
  List<Object?> get props => [bookingId, reason, description];
}

class RespondToDisputeSubmitEvent extends DisputeEvent {
  const RespondToDisputeSubmitEvent({
    required this.disputeId,
    required this.response,
  });
  final String disputeId;
  final String response;
  @override
  List<Object?> get props => [disputeId, response];
}
