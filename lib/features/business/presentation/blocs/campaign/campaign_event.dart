part of 'campaign_bloc.dart';

sealed class CampaignEvent extends Equatable {
  const CampaignEvent();
}

class LoadCampaignsEvent extends CampaignEvent {
  const LoadCampaignsEvent({this.status});
  final CampaignStatus? status;
  @override
  List<Object?> get props => [status];
}

class LoadMoreCampaignsEvent extends CampaignEvent {
  const LoadMoreCampaignsEvent();
  @override
  List<Object?> get props => [];
}

class LoadCampaignDetailEvent extends CampaignEvent {
  const LoadCampaignDetailEvent({required this.campaignId});
  final String campaignId;
  @override
  List<Object?> get props => [campaignId];
}

class CreateCampaignEvent extends CampaignEvent {
  const CreateCampaignEvent({required this.params});
  final CreateCampaignParams params;
  @override
  List<Object?> get props => [params];
}

class UpdateCampaignEvent extends CampaignEvent {
  const UpdateCampaignEvent({required this.params});
  final UpdateCampaignParams params;
  @override
  List<Object?> get props => [params];
}

class DeleteCampaignEvent extends CampaignEvent {
  const DeleteCampaignEvent({required this.campaignId});
  final String campaignId;
  @override
  List<Object?> get props => [campaignId];
}

class PublishCampaignEvent extends CampaignEvent {
  const PublishCampaignEvent({required this.campaignId});
  final String campaignId;
  @override
  List<Object?> get props => [campaignId];
}

class FilterCampaignsByStatusEvent extends CampaignEvent {
  const FilterCampaignsByStatusEvent({this.status});
  final CampaignStatus? status;
  @override
  List<Object?> get props => [status];
}
