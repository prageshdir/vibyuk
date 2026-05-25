part of 'admin_disputes_bloc.dart';

sealed class AdminDisputesEvent {}

final class AdminDisputesFetchDisputes extends AdminDisputesEvent {
  final bool refresh;
  AdminDisputesFetchDisputes({this.refresh = false});
}

final class AdminDisputesLoadMore extends AdminDisputesEvent {}

final class AdminDisputesSearchChanged extends AdminDisputesEvent {
  final String query;
  AdminDisputesSearchChanged(this.query);
}

final class AdminDisputesStatusFilterChanged extends AdminDisputesEvent {
  final DisputeStatus? status;
  AdminDisputesStatusFilterChanged(this.status);
}

final class AdminDisputesTypeFilterChanged extends AdminDisputesEvent {
  final DisputeType? type;
  AdminDisputesTypeFilterChanged(this.type);
}

final class AdminDisputesSelectDispute extends AdminDisputesEvent {
  final String disputeId;
  AdminDisputesSelectDispute(this.disputeId);
}

final class AdminDisputesAssign extends AdminDisputesEvent {
  final String disputeId;
  final String moderatorId;
  AdminDisputesAssign({required this.disputeId, required this.moderatorId});
}

final class AdminDisputesResolve extends AdminDisputesEvent {
  final String disputeId;
  final DisputeResolution resolution;
  final String note;
  final double? refundAmount;

  AdminDisputesResolve({
    required this.disputeId,
    required this.resolution,
    required this.note,
    this.refundAmount,
  });
}

final class AdminDisputesSendMessage extends AdminDisputesEvent {
  final String disputeId;
  final String content;
  AdminDisputesSendMessage({required this.disputeId, required this.content});
}
