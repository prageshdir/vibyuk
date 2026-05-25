import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_dispute_usecases.dart';

part 'admin_disputes_event.dart';
part 'admin_disputes_state.dart';

class AdminDisputesBloc
    extends BaseBloc<AdminDisputesEvent, AdminDisputesState> {
  final GetDisputesUseCase _getDisputes;
  final GetDisputeDetailUseCase _getDisputeDetail;
  final AssignDisputeUseCase _assignDispute;
  final ResolveDisputeUseCase _resolveDispute;
  final AddDisputeMessageUseCase _addMessage;

  AdminDisputesBloc({
    required GetDisputesUseCase getDisputes,
    required GetDisputeDetailUseCase getDisputeDetail,
    required AssignDisputeUseCase assignDispute,
    required ResolveDisputeUseCase resolveDispute,
    required AddDisputeMessageUseCase addMessage,
  })  : _getDisputes = getDisputes,
        _getDisputeDetail = getDisputeDetail,
        _assignDispute = assignDispute,
        _resolveDispute = resolveDispute,
        _addMessage = addMessage,
        super(const AdminDisputesState()) {
    on<AdminDisputesFetchDisputes>(_onFetchDisputes);
    on<AdminDisputesLoadMore>(_onLoadMore);
    on<AdminDisputesSearchChanged>(_onSearchChanged);
    on<AdminDisputesStatusFilterChanged>(_onStatusFilterChanged);
    on<AdminDisputesTypeFilterChanged>(_onTypeFilterChanged);
    on<AdminDisputesSelectDispute>(_onSelectDispute);
    on<AdminDisputesAssign>(_onAssign);
    on<AdminDisputesResolve>(_onResolve);
    on<AdminDisputesSendMessage>(_onSendMessage);
  }

  Future<void> _onFetchDisputes(
    AdminDisputesFetchDisputes event,
    Emitter<AdminDisputesState> emit,
  ) async {
    emit(state.copyWith(
      status: AdminDisputesStatus.loading,
      disputes: event.refresh ? [] : state.disputes,
      currentPage: event.refresh ? 0 : state.currentPage,
    ));

    final result = await _getDisputes(GetDisputesParams(
      page: 1,
      statusFilter: state.statusFilter,
      typeFilter: state.typeFilter,
      searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminDisputesStatus.error,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: AdminDisputesStatus.loaded,
        disputes: page.items,
        currentPage: 1,
        hasMore: page.hasNextPage,
      )),
    );
  }

  Future<void> _onLoadMore(
    AdminDisputesLoadMore event,
    Emitter<AdminDisputesState> emit,
  ) async {
    if (!state.hasMore || state.status == AdminDisputesStatus.loadingMore) {
      return;
    }
    emit(state.copyWith(status: AdminDisputesStatus.loadingMore));

    final result = await _getDisputes(GetDisputesParams(
      page: state.currentPage + 1,
      statusFilter: state.statusFilter,
      typeFilter: state.typeFilter,
      searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminDisputesStatus.loaded,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: AdminDisputesStatus.loaded,
        disputes: [...state.disputes, ...page.items],
        currentPage: state.currentPage + 1,
        hasMore: page.hasNextPage,
      )),
    );
  }

  Future<void> _onSearchChanged(
    AdminDisputesSearchChanged event,
    Emitter<AdminDisputesState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(AdminDisputesFetchDisputes(refresh: true));
  }

  Future<void> _onStatusFilterChanged(
    AdminDisputesStatusFilterChanged event,
    Emitter<AdminDisputesState> emit,
  ) async {
    emit(state.copyWith(statusFilter: () => event.status));
    add(AdminDisputesFetchDisputes(refresh: true));
  }

  Future<void> _onTypeFilterChanged(
    AdminDisputesTypeFilterChanged event,
    Emitter<AdminDisputesState> emit,
  ) async {
    emit(state.copyWith(typeFilter: () => event.type));
    add(AdminDisputesFetchDisputes(refresh: true));
  }

  Future<void> _onSelectDispute(
    AdminDisputesSelectDispute event,
    Emitter<AdminDisputesState> emit,
  ) async {
    final result =
        await _getDisputeDetail(DisputeIdParams(disputeId: event.disputeId));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (dispute) => emit(state.copyWith(selectedDispute: dispute)),
    );
  }

  Future<void> _onAssign(
    AdminDisputesAssign event,
    Emitter<AdminDisputesState> emit,
  ) async {
    emit(state.copyWith(isActioning: true));
    final result = await _assignDispute(AssignDisputeParams(
      disputeId: event.disputeId,
      moderatorId: event.moderatorId,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        isActioning: false,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        isActioning: false,
        selectedDispute: updated,
        disputes: state.disputes
            .map((d) => d.id == updated.id ? updated : d)
            .toList(),
        actionSuccess: 'Dispute assigned',
      )),
    );
  }

  Future<void> _onResolve(
    AdminDisputesResolve event,
    Emitter<AdminDisputesState> emit,
  ) async {
    emit(state.copyWith(isActioning: true));
    final result = await _resolveDispute(ResolveDisputeParams(
      disputeId: event.disputeId,
      resolution: event.resolution,
      note: event.note,
      refundAmount: event.refundAmount,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        isActioning: false,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        isActioning: false,
        selectedDispute: updated,
        disputes: state.disputes
            .map((d) => d.id == updated.id ? updated : d)
            .toList(),
        actionSuccess: 'Dispute resolved',
      )),
    );
  }

  Future<void> _onSendMessage(
    AdminDisputesSendMessage event,
    Emitter<AdminDisputesState> emit,
  ) async {
    emit(state.copyWith(isActioning: true));
    final result = await _addMessage(AddDisputeMessageParams(
      disputeId: event.disputeId,
      content: event.content,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        isActioning: false,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        isActioning: false,
        selectedDispute: updated,
      )),
    );
  }
}
