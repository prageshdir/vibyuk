part of 'milestone_bloc.dart';

sealed class MilestoneEvent extends Equatable {
  const MilestoneEvent();
}

class LoadMilestonesEvent extends MilestoneEvent {
  const LoadMilestonesEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class SubmitMilestoneDeliverableEvent extends MilestoneEvent {
  const SubmitMilestoneDeliverableEvent({
    required this.bookingId,
    required this.milestoneId,
    required this.deliverableUrl,
    this.notes,
  });
  final String bookingId;
  final String milestoneId;
  final String deliverableUrl;
  final String? notes;
  @override
  List<Object?> get props =>
      [bookingId, milestoneId, deliverableUrl, notes];
}

class ApproveMilestoneDeliverableEvent extends MilestoneEvent {
  const ApproveMilestoneDeliverableEvent(
      {required this.bookingId, required this.milestoneId});
  final String bookingId;
  final String milestoneId;
  @override
  List<Object?> get props => [bookingId, milestoneId];
}

class RejectMilestoneDeliverableEvent extends MilestoneEvent {
  const RejectMilestoneDeliverableEvent({
    required this.bookingId,
    required this.milestoneId,
    required this.reason,
  });
  final String bookingId;
  final String milestoneId;
  final String reason;
  @override
  List<Object?> get props => [bookingId, milestoneId, reason];
}
