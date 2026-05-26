part of 'influencer_campaign_bloc.dart';

sealed class InfluencerCampaignEvent extends Equatable {
  const InfluencerCampaignEvent();
}

class LoadInfluencerCampaignsEvent extends InfluencerCampaignEvent {
  const LoadInfluencerCampaignsEvent({this.status});
  final InfluencerCampaignStatus? status;
  @override
  List<Object?> get props => [status];
}

class LoadMoreInfluencerCampaignsEvent extends InfluencerCampaignEvent {
  const LoadMoreInfluencerCampaignsEvent();
  @override
  List<Object?> get props => [];
}

class FilterInfluencerCampaignsEvent extends InfluencerCampaignEvent {
  const FilterInfluencerCampaignsEvent({this.status});
  final InfluencerCampaignStatus? status;
  @override
  List<Object?> get props => [status];
}

class ApproveDeliverableEvent extends InfluencerCampaignEvent {
  const ApproveDeliverableEvent({
    required this.deliverableId,
    required this.campaignId,
  });
  final String deliverableId;
  final String campaignId;
  @override
  List<Object?> get props => [deliverableId, campaignId];
}

class RequestRevisionEvent extends InfluencerCampaignEvent {
  const RequestRevisionEvent({
    required this.deliverableId,
    required this.campaignId,
    required this.note,
  });
  final String deliverableId;
  final String campaignId;
  final String note;
  @override
  List<Object?> get props => [deliverableId, campaignId, note];
}

class MarkDeliverablePublishedEvent extends InfluencerCampaignEvent {
  const MarkDeliverablePublishedEvent({
    required this.deliverableId,
    required this.campaignId,
    required this.postUrl,
  });
  final String deliverableId;
  final String campaignId;
  final String postUrl;
  @override
  List<Object?> get props => [deliverableId, campaignId, postUrl];
}
