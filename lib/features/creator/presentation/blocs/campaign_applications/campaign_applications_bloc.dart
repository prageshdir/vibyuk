import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/campaign_application_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/campaigns/apply_to_campaign_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/campaigns/get_applications_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/campaigns/withdraw_application_use_case.dart';

part 'campaign_applications_event.dart';
part 'campaign_applications_state.dart';

class CampaignApplicationsBloc
    extends BaseBloc<CampaignApplicationsEvent, CampaignApplicationsState> {
  CampaignApplicationsBloc({
    required GetApplicationsUseCase getApplications,
    required ApplyToCampaignUseCase apply,
    required WithdrawApplicationUseCase withdraw,
  })  : _getApplications = getApplications,
        _apply = apply,
        _withdraw = withdraw,
        super(const CampaignApplicationsInitialState()) {
    on<LoadApplicationsEvent>(_onLoad);
    on<LoadMoreApplicationsEvent>(_onLoadMore);
    on<FilterApplicationsEvent>(_onFilter);
    on<ApplyToCampaignEvent>(_onApply);
    on<WithdrawApplicationEvent>(_onWithdraw);
  }

  final GetApplicationsUseCase _getApplications;
  final ApplyToCampaignUseCase _apply;
  final WithdrawApplicationUseCase _withdraw;

  int _currentPage = 1;
  static const int _pageSize = 20;
  ApplicationStatus? _statusFilter;

  Future<void> _onLoad(LoadApplicationsEvent event,
      Emitter<CampaignApplicationsState> emit) async {
    emit(const CampaignApplicationsLoadingState());
    _currentPage = 1;
    _statusFilter = event.statusFilter;
    final result = await _getApplications(GetApplicationsParams(
      page: _currentPage,
      pageSize: _pageSize,
      statusFilter: _statusFilter,
    ));
    result.fold(
      (f) => emit(CampaignApplicationsErrorState(failure: f)),
      (r) => emit(CampaignApplicationsLoadedState(
        applications: r.items,
        hasMore: r.hasNextPage,
        currentPage: _currentPage,
        statusFilter: _statusFilter,
      )),
    );
  }

  Future<void> _onLoadMore(LoadMoreApplicationsEvent event,
      Emitter<CampaignApplicationsState> emit) async {
    if (state is! CampaignApplicationsLoadedState) return;
    final current = state as CampaignApplicationsLoadedState;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getApplications(GetApplicationsParams(
      page: _currentPage + 1,
      pageSize: _pageSize,
      statusFilter: _statusFilter,
    ));
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (r) {
        _currentPage++;
        emit(current.copyWith(
          applications: [...current.applications, ...r.items],
          hasMore: r.hasNextPage,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onFilter(FilterApplicationsEvent event,
      Emitter<CampaignApplicationsState> emit) async {
    add(LoadApplicationsEvent(statusFilter: event.statusFilter));
  }

  Future<void> _onApply(
      ApplyToCampaignEvent event, Emitter<CampaignApplicationsState> emit) async {
    if (state is! CampaignApplicationsLoadedState) return;
    final current = state as CampaignApplicationsLoadedState;
    emit(current.copyWith(isSubmitting: true));
    final result = await _apply(ApplyToCampaignParams(
      campaignId: event.campaignId,
      coverLetter: event.coverLetter,
      portfolioItemIds: event.portfolioItemIds,
      proposedRate: event.proposedRate,
      currency: event.currency,
    ));
    result.fold(
      (f) => emit(current.copyWith(isSubmitting: false, submitError: f)),
      (app) => emit(current.copyWith(
        applications: [app, ...current.applications],
        isSubmitting: false,
        submitSuccess: true,
      )),
    );
  }

  Future<void> _onWithdraw(WithdrawApplicationEvent event,
      Emitter<CampaignApplicationsState> emit) async {
    if (state is! CampaignApplicationsLoadedState) return;
    final current = state as CampaignApplicationsLoadedState;
    final optimistic = current.applications
        .where((a) => a.id != event.applicationId)
        .toList();
    emit(current.copyWith(applications: optimistic));
    final result = await _withdraw(
        WithdrawApplicationParams(applicationId: event.applicationId));
    result.fold(
      (_) => emit(current),
      (_) => null,
    );
  }
}
