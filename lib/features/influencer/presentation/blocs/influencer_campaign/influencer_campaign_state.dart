part of 'influencer_campaign_bloc.dart';

sealed class InfluencerCampaignState extends Equatable {
  const InfluencerCampaignState();
}

class InfluencerCampaignInitial extends InfluencerCampaignState {
  const InfluencerCampaignInitial();
  @override
  List<Object?> get props => [];
}

class InfluencerCampaignLoading extends InfluencerCampaignState {
  const InfluencerCampaignLoading();
  @override
  List<Object?> get props => [];
}

class InfluencerCampaignLoaded extends InfluencerCampaignState {
  const InfluencerCampaignLoaded({
    required this.campaigns,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.statusFilter,
  });

  final List<InfluencerCampaignEntity> campaigns;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final InfluencerCampaignStatus? statusFilter;

  InfluencerCampaignLoaded copyWith({
    List<InfluencerCampaignEntity>? campaigns,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    InfluencerCampaignStatus? statusFilter,
  }) =>
      InfluencerCampaignLoaded(
        campaigns: campaigns ?? this.campaigns,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? false,
        statusFilter: statusFilter ?? this.statusFilter,
      );

  @override
  List<Object?> get props =>
      [campaigns, hasMore, currentPage, isLoadingMore, statusFilter];
}

class InfluencerCampaignError extends InfluencerCampaignState {
  const InfluencerCampaignError({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
