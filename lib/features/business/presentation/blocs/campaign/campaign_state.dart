part of 'campaign_bloc.dart';

sealed class CampaignState extends Equatable {
  const CampaignState();
}

class CampaignInitialState extends CampaignState {
  const CampaignInitialState();
  @override
  List<Object?> get props => [];
}

class CampaignLoadingState extends CampaignState {
  const CampaignLoadingState();
  @override
  List<Object?> get props => [];
}

class CampaignsLoadedState extends CampaignState {
  const CampaignsLoadedState({
    required this.campaigns,
    required this.hasMore,
    required this.currentPage,
    this.filterStatus,
    this.isLoadingMore = false,
  });

  final List<CampaignEntity> campaigns;
  final bool hasMore;
  final int currentPage;
  final CampaignStatus? filterStatus;
  final bool isLoadingMore;

  CampaignsLoadedState copyWith({
    List<CampaignEntity>? campaigns,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) =>
      CampaignsLoadedState(
        campaigns: campaigns ?? this.campaigns,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        filterStatus: filterStatus,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [campaigns, hasMore, currentPage, filterStatus, isLoadingMore];
}

class CampaignDetailLoadedState extends CampaignState {
  const CampaignDetailLoadedState({required this.campaign});
  final CampaignEntity campaign;
  @override
  List<Object?> get props => [campaign];
}

class CampaignCreatedState extends CampaignState {
  const CampaignCreatedState({required this.campaign});
  final CampaignEntity campaign;
  @override
  List<Object?> get props => [campaign];
}

class CampaignUpdatedState extends CampaignState {
  const CampaignUpdatedState({required this.campaign});
  final CampaignEntity campaign;
  @override
  List<Object?> get props => [campaign];
}

class CampaignDeletedState extends CampaignState {
  const CampaignDeletedState({required this.campaignId});
  final String campaignId;
  @override
  List<Object?> get props => [campaignId];
}

class CampaignPublishedState extends CampaignState {
  const CampaignPublishedState({required this.campaign});
  final CampaignEntity campaign;
  @override
  List<Object?> get props => [campaign];
}

class CampaignErrorState extends CampaignState {
  const CampaignErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
