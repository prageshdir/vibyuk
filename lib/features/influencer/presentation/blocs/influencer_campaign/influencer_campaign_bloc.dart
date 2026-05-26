import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';
import 'package:vibyuk/features/influencer/domain/usecases/get_influencer_campaigns_use_case.dart';
import 'package:vibyuk/features/influencer/domain/usecases/review_deliverable_use_case.dart';

part 'influencer_campaign_event.dart';
part 'influencer_campaign_state.dart';

class InfluencerCampaignBloc
    extends BaseBloc<InfluencerCampaignEvent, InfluencerCampaignState> {
  InfluencerCampaignBloc({
    required GetInfluencerCampaignsUseCase getCampaigns,
    required ApproveDeliverableUseCase approveDeliverable,
    required RequestRevisionUseCase requestRevision,
    required MarkPublishedUseCase markPublished,
  })  : _getCampaigns = getCampaigns,
        _approveDeliverable = approveDeliverable,
        _requestRevision = requestRevision,
        _markPublished = markPublished,
        super(const InfluencerCampaignInitial()) {
    on<LoadInfluencerCampaignsEvent>(_onLoad);
    on<LoadMoreInfluencerCampaignsEvent>(_onLoadMore);
    on<FilterInfluencerCampaignsEvent>(_onFilter);
    on<ApproveDeliverableEvent>(_onApprove);
    on<RequestRevisionEvent>(_onRequestRevision);
    on<MarkDeliverablePublishedEvent>(_onMarkPublished);
  }

  final GetInfluencerCampaignsUseCase _getCampaigns;
  final ApproveDeliverableUseCase _approveDeliverable;
  final RequestRevisionUseCase _requestRevision;
  final MarkPublishedUseCase _markPublished;
  int _currentPage = 1;
  static const int _pageSize = 20;

  Future<void> _onLoad(LoadInfluencerCampaignsEvent event,
      Emitter<InfluencerCampaignState> emit) async {
    emit(const InfluencerCampaignLoading());
    _currentPage = 1;
    final result = await _getCampaigns(GetInfluencerCampaignsParams(
      page: _currentPage,
      pageSize: _pageSize,
      status: event.status,
    ));
    result.fold(
      (f) => emit(InfluencerCampaignError(failure: f)),
      (r) => emit(InfluencerCampaignLoaded(
        campaigns: r.items,
        hasMore: r.hasNextPage,
        currentPage: _currentPage,
        statusFilter: event.status,
      )),
    );
  }

  Future<void> _onLoadMore(LoadMoreInfluencerCampaignsEvent event,
      Emitter<InfluencerCampaignState> emit) async {
    if (state is! InfluencerCampaignLoaded) return;
    final current = state as InfluencerCampaignLoaded;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getCampaigns(GetInfluencerCampaignsParams(
      page: _currentPage + 1,
      pageSize: _pageSize,
      status: current.statusFilter,
    ));
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (r) {
        _currentPage++;
        emit(current.copyWith(
          campaigns: [...current.campaigns, ...r.items],
          hasMore: r.hasNextPage,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onFilter(FilterInfluencerCampaignsEvent event,
      Emitter<InfluencerCampaignState> emit) async {
    add(LoadInfluencerCampaignsEvent(status: event.status));
  }

  Future<void> _onApprove(ApproveDeliverableEvent event,
      Emitter<InfluencerCampaignState> emit) async {
    if (state is! InfluencerCampaignLoaded) return;
    final current = state as InfluencerCampaignLoaded;
    final result = await _approveDeliverable(DeliverableActionParams(
      deliverableId: event.deliverableId,
      campaignId: event.campaignId,
    ));
    result.fold(
      (_) => null,
      (updated) => emit(current.copyWith(
        campaigns: _updateDeliverable(current.campaigns, updated),
      )),
    );
  }

  Future<void> _onRequestRevision(RequestRevisionEvent event,
      Emitter<InfluencerCampaignState> emit) async {
    if (state is! InfluencerCampaignLoaded) return;
    final current = state as InfluencerCampaignLoaded;
    final result = await _requestRevision(RequestRevisionParams(
      deliverableId: event.deliverableId,
      campaignId: event.campaignId,
      note: event.note,
    ));
    result.fold(
      (_) => null,
      (updated) => emit(current.copyWith(
        campaigns: _updateDeliverable(current.campaigns, updated),
      )),
    );
  }

  Future<void> _onMarkPublished(MarkDeliverablePublishedEvent event,
      Emitter<InfluencerCampaignState> emit) async {
    if (state is! InfluencerCampaignLoaded) return;
    final current = state as InfluencerCampaignLoaded;
    final result = await _markPublished(MarkPublishedParams(
      deliverableId: event.deliverableId,
      campaignId: event.campaignId,
      postUrl: event.postUrl,
    ));
    result.fold(
      (_) => null,
      (updated) => emit(current.copyWith(
        campaigns: _updateDeliverable(current.campaigns, updated),
      )),
    );
  }

  List<InfluencerCampaignEntity> _updateDeliverable(
    List<InfluencerCampaignEntity> campaigns,
    ContentDeliverableEntity updated,
  ) =>
      campaigns.map((c) {
        if (c.id != updated.campaignId) return c;
        final deliverables = c.deliverables
            .map((d) => d.id == updated.id ? updated : d)
            .toList();
        return InfluencerCampaignEntity(
          id: c.id,
          businessId: c.businessId,
          title: c.title,
          description: c.description,
          budgetPaise: c.budgetPaise,
          status: c.status,
          startDate: c.startDate,
          endDate: c.endDate,
          categories: c.categories,
          platforms: c.platforms,
          languages: c.languages,
          minFollowers: c.minFollowers,
          maxFollowers: c.maxFollowers,
          minEngagementRate: c.minEngagementRate,
          maxInfluencers: c.maxInfluencers,
          confirmedInfluencerIds: c.confirmedInfluencerIds,
          deliverables: deliverables,
          analytics: c.analytics,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        );
      }).toList();
}
