import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_campaigns_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class CampaignListEvent extends Equatable {
  const CampaignListEvent();
  @override
  List<Object?> get props => [];
}

final class CampaignListLoaded extends CampaignListEvent {
  const CampaignListLoaded({this.destinationId, this.status});
  final String? destinationId;
  final CampaignStatus? status;
  @override
  List<Object?> get props => [destinationId, status];
}

final class CampaignListNextPage extends CampaignListEvent {
  const CampaignListNextPage();
}

final class CampaignListStatusFiltered extends CampaignListEvent {
  const CampaignListStatusFiltered(this.status);
  final CampaignStatus? status;
  @override
  List<Object?> get props => [status];
}

final class CampaignListRefreshed extends CampaignListEvent {
  const CampaignListRefreshed();
}

// ── State ─────────────────────────────────────────────────────────────────────

final class CampaignListState extends Equatable {
  const CampaignListState({
    this.status = CampaignListStatus.initial,
    this.campaigns = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedStatus,
    this.destinationId,
    this.errorMessage,
  });

  final CampaignListStatus status;
  final List<TourismCampaignEntity> campaigns;
  final int currentPage;
  final bool hasMore;
  final CampaignStatus? selectedStatus;
  final String? destinationId;
  final String? errorMessage;

  bool get isLoadingMore => status == CampaignListStatus.loadingMore;

  CampaignListState copyWith({
    CampaignListStatus? status,
    List<TourismCampaignEntity>? campaigns,
    int? currentPage,
    bool? hasMore,
    CampaignStatus? selectedStatus,
    bool clearStatus = false,
    String? destinationId,
    String? errorMessage,
  }) =>
      CampaignListState(
        status: status ?? this.status,
        campaigns: campaigns ?? this.campaigns,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        selectedStatus:
            clearStatus ? null : selectedStatus ?? this.selectedStatus,
        destinationId: destinationId ?? this.destinationId,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        campaigns,
        currentPage,
        hasMore,
        selectedStatus,
        destinationId,
        errorMessage,
      ];
}

enum CampaignListStatus { initial, loading, loadingMore, loaded, error }

// ── BLoC ─────────────────────────────────────────────────────────────────────

class CampaignListBloc
    extends BaseBloc<CampaignListEvent, CampaignListState> {
  CampaignListBloc({required GetCampaignsUseCase getCampaigns})
      : _getCampaigns = getCampaigns,
        super(const CampaignListState()) {
    on<CampaignListLoaded>(_onLoaded);
    on<CampaignListNextPage>(_onNextPage);
    on<CampaignListStatusFiltered>(_onStatusFiltered);
    on<CampaignListRefreshed>(_onRefreshed);
  }

  final GetCampaignsUseCase _getCampaigns;

  Future<void> _onLoaded(
    CampaignListLoaded event,
    Emitter<CampaignListState> emit,
  ) async {
    emit(state.copyWith(
      status: CampaignListStatus.loading,
      destinationId: event.destinationId,
      selectedStatus: event.status,
    ));

    final result = await _getCampaigns(GetCampaignsParams(
      page: 1,
      destinationId: event.destinationId,
      status: event.status,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CampaignListStatus.error,
        errorMessage: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        status: CampaignListStatus.loaded,
        campaigns: paginated.items,
        currentPage: 1,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onNextPage(
    CampaignListNextPage event,
    Emitter<CampaignListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(status: CampaignListStatus.loadingMore));
    final nextPage = state.currentPage + 1;

    final result = await _getCampaigns(GetCampaignsParams(
      page: nextPage,
      destinationId: state.destinationId,
      status: state.selectedStatus,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CampaignListStatus.loaded,
        errorMessage: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        status: CampaignListStatus.loaded,
        campaigns: [...state.campaigns, ...paginated.items],
        currentPage: nextPage,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onStatusFiltered(
    CampaignListStatusFiltered event,
    Emitter<CampaignListState> emit,
  ) {
    add(CampaignListLoaded(
      destinationId: state.destinationId,
      status: event.status,
    ));
    return Future.value();
  }

  Future<void> _onRefreshed(
    CampaignListRefreshed event,
    Emitter<CampaignListState> emit,
  ) {
    add(CampaignListLoaded(
      destinationId: state.destinationId,
      status: state.selectedStatus,
    ));
    return Future.value();
  }
}
