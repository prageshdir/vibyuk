import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/create_campaign_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/delete_campaign_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/get_campaign_detail_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/get_campaigns_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/publish_campaign_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/update_campaign_use_case.dart';

part 'campaign_event.dart';
part 'campaign_state.dart';

class CampaignBloc extends BaseBloc<CampaignEvent, CampaignState> {
  CampaignBloc({
    required GetCampaignsUseCase getCampaigns,
    required GetCampaignDetailUseCase getCampaignDetail,
    required CreateCampaignUseCase createCampaign,
    required UpdateCampaignUseCase updateCampaign,
    required DeleteCampaignUseCase deleteCampaign,
    required PublishCampaignUseCase publishCampaign,
  })  : _getCampaigns = getCampaigns,
        _getCampaignDetail = getCampaignDetail,
        _createCampaign = createCampaign,
        _updateCampaign = updateCampaign,
        _deleteCampaign = deleteCampaign,
        _publishCampaign = publishCampaign,
        super(const CampaignInitialState()) {
    on<LoadCampaignsEvent>(_onLoad);
    on<LoadMoreCampaignsEvent>(_onLoadMore);
    on<LoadCampaignDetailEvent>(_onLoadDetail);
    on<CreateCampaignEvent>(_onCreate);
    on<UpdateCampaignEvent>(_onUpdate);
    on<DeleteCampaignEvent>(_onDelete);
    on<PublishCampaignEvent>(_onPublish);
    on<FilterCampaignsByStatusEvent>(_onFilter);
  }

  final GetCampaignsUseCase _getCampaigns;
  final GetCampaignDetailUseCase _getCampaignDetail;
  final CreateCampaignUseCase _createCampaign;
  final UpdateCampaignUseCase _updateCampaign;
  final DeleteCampaignUseCase _deleteCampaign;
  final PublishCampaignUseCase _publishCampaign;

  Future<void> _onLoad(
      LoadCampaignsEvent event, Emitter<CampaignState> emit) async {
    emit(const CampaignLoadingState());
    final result = await _getCampaigns(
        GetCampaignsParams(status: event.status));
    result.fold(
      (f) => emit(CampaignErrorState(failure: f)),
      (page) => emit(CampaignsLoadedState(
        campaigns: page.items,
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        filterStatus: event.status,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMoreCampaignsEvent event, Emitter<CampaignState> emit) async {
    if (state is! CampaignsLoadedState) return;
    final loaded = state as CampaignsLoadedState;
    if (!loaded.hasMore || loaded.isLoadingMore) return;

    emit(loaded.copyWith(isLoadingMore: true));
    final result = await _getCampaigns(GetCampaignsParams(
      status: loaded.filterStatus,
      page: loaded.currentPage + 1,
    ));
    result.fold(
      (f) => emit(CampaignErrorState(failure: f)),
      (page) => emit(loaded.copyWith(
        campaigns: [...loaded.campaigns, ...page.items],
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onLoadDetail(
      LoadCampaignDetailEvent event, Emitter<CampaignState> emit) async {
    emit(const CampaignLoadingState());
    final result = await _getCampaignDetail(
        GetCampaignDetailParams(campaignId: event.campaignId));
    result.fold(
      (f) => emit(CampaignErrorState(failure: f)),
      (c) => emit(CampaignDetailLoadedState(campaign: c)),
    );
  }

  Future<void> _onCreate(
      CreateCampaignEvent event, Emitter<CampaignState> emit) async {
    emit(const CampaignLoadingState());
    final result = await _createCampaign(event.params);
    result.fold(
      (f) => emit(CampaignErrorState(failure: f)),
      (c) => emit(CampaignCreatedState(campaign: c)),
    );
  }

  Future<void> _onUpdate(
      UpdateCampaignEvent event, Emitter<CampaignState> emit) async {
    emit(const CampaignLoadingState());
    final result = await _updateCampaign(event.params);
    result.fold(
      (f) => emit(CampaignErrorState(failure: f)),
      (c) => emit(CampaignUpdatedState(campaign: c)),
    );
  }

  Future<void> _onDelete(
      DeleteCampaignEvent event, Emitter<CampaignState> emit) async {
    emit(const CampaignLoadingState());
    final result = await _deleteCampaign(
        DeleteCampaignParams(campaignId: event.campaignId));
    result.fold(
      (f) => emit(CampaignErrorState(failure: f)),
      (_) => emit(CampaignDeletedState(campaignId: event.campaignId)),
    );
  }

  Future<void> _onPublish(
      PublishCampaignEvent event, Emitter<CampaignState> emit) async {
    emit(const CampaignLoadingState());
    final result = await _publishCampaign(
        PublishCampaignParams(campaignId: event.campaignId));
    result.fold(
      (f) => emit(CampaignErrorState(failure: f)),
      (c) => emit(CampaignPublishedState(campaign: c)),
    );
  }

  void _onFilter(
      FilterCampaignsByStatusEvent event, Emitter<CampaignState> emit) {
    add(LoadCampaignsEvent(status: event.status));
  }
}
