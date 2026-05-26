part of 'campaign_applications_bloc.dart';

sealed class CampaignApplicationsEvent extends Equatable {
  const CampaignApplicationsEvent();
}

class LoadApplicationsEvent extends CampaignApplicationsEvent {
  const LoadApplicationsEvent({this.statusFilter});
  final ApplicationStatus? statusFilter;
  @override
  List<Object?> get props => [statusFilter];
}

class LoadMoreApplicationsEvent extends CampaignApplicationsEvent {
  const LoadMoreApplicationsEvent();
  @override
  List<Object?> get props => [];
}

class FilterApplicationsEvent extends CampaignApplicationsEvent {
  const FilterApplicationsEvent({this.statusFilter});
  final ApplicationStatus? statusFilter;
  @override
  List<Object?> get props => [statusFilter];
}

class ApplyToCampaignEvent extends CampaignApplicationsEvent {
  const ApplyToCampaignEvent({
    required this.campaignId,
    this.coverLetter,
    required this.portfolioItemIds,
    required this.proposedRate,
    required this.currency,
  });
  final String campaignId;
  final String? coverLetter;
  final List<String> portfolioItemIds;
  final double proposedRate;
  final String currency;
  @override
  List<Object?> get props =>
      [campaignId, coverLetter, portfolioItemIds, proposedRate, currency];
}

class WithdrawApplicationEvent extends CampaignApplicationsEvent {
  const WithdrawApplicationEvent({required this.applicationId});
  final String applicationId;
  @override
  List<Object?> get props => [applicationId];
}
