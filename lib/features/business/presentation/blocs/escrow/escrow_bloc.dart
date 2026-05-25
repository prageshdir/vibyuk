import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/escrow_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_escrow_details_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/release_escrow_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/request_refund_use_case.dart';

part 'escrow_event.dart';
part 'escrow_state.dart';

class EscrowBloc extends BaseBloc<EscrowEvent, EscrowState> {
  EscrowBloc({
    required GetEscrowDetailsUseCase getEscrowDetails,
    required ReleaseEscrowUseCase releaseEscrow,
    required RequestRefundUseCase requestRefund,
  })  : _getEscrowDetails = getEscrowDetails,
        _releaseEscrow = releaseEscrow,
        _requestRefund = requestRefund,
        super(const EscrowInitialState()) {
    on<LoadEscrowEvent>(_onLoad);
    on<ReleaseEscrowEvent>(_onRelease);
    on<RequestRefundEvent>(_onRefund);
  }

  final GetEscrowDetailsUseCase _getEscrowDetails;
  final ReleaseEscrowUseCase _releaseEscrow;
  final RequestRefundUseCase _requestRefund;

  Future<void> _onLoad(LoadEscrowEvent event, Emitter<EscrowState> emit) async {
    emit(const EscrowLoadingState());
    final result = await _getEscrowDetails(event.bookingId);
    result.fold(
      (f) => emit(EscrowErrorState(failure: f)),
      (escrow) => emit(EscrowLoadedState(escrow: escrow)),
    );
  }

  Future<void> _onRelease(ReleaseEscrowEvent event, Emitter<EscrowState> emit) async {
    if (state is! EscrowLoadedState) return;
    emit(const EscrowActionInProgressState());
    final result = await _releaseEscrow(
        ReleaseEscrowParams(escrowId: event.escrowId, milestoneId: event.milestoneId));
    result.fold(
      (f) => emit(EscrowErrorState(failure: f)),
      (escrow) => emit(EscrowLoadedState(escrow: escrow, lastActionSuccess: 'Escrow released')),
    );
  }

  Future<void> _onRefund(RequestRefundEvent event, Emitter<EscrowState> emit) async {
    if (state is! EscrowLoadedState) return;
    emit(const EscrowActionInProgressState());
    final result = await _requestRefund(
        RequestRefundParams(escrowId: event.escrowId, reason: event.reason));
    result.fold(
      (f) => emit(EscrowErrorState(failure: f)),
      (escrow) => emit(EscrowLoadedState(escrow: escrow, lastActionSuccess: 'Refund requested')),
    );
  }
}
