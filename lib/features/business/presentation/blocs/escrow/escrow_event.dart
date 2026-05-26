part of 'escrow_bloc.dart';

sealed class EscrowEvent extends Equatable {
  const EscrowEvent();
}

class LoadEscrowEvent extends EscrowEvent {
  const LoadEscrowEvent(this.bookingId);
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class ReleaseEscrowEvent extends EscrowEvent {
  const ReleaseEscrowEvent({required this.escrowId, this.milestoneId});
  final String escrowId;
  final String? milestoneId;
  @override
  List<Object?> get props => [escrowId, milestoneId];
}

class RequestRefundEvent extends EscrowEvent {
  const RequestRefundEvent({required this.escrowId, required this.reason});
  final String escrowId;
  final String reason;
  @override
  List<Object?> get props => [escrowId, reason];
}
