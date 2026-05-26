import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_dispute_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/dispute/dispute_use_cases.dart';

part 'dispute_event.dart';
part 'dispute_state.dart';

class DisputeBloc extends BaseBloc<DisputeEvent, DisputeState> {
  DisputeBloc({
    required GetDisputeUseCase getDispute,
    required OpenDisputeUseCase openDispute,
    required RespondToDisputeUseCase respondToDispute,
  })  : _getDispute = getDispute,
        _openDispute = openDispute,
        _respondToDispute = respondToDispute,
        super(const DisputeInitialState()) {
    on<LoadDisputeEvent>(_onLoad);
    on<OpenDisputeSubmitEvent>(_onOpen);
    on<RespondToDisputeSubmitEvent>(_onRespond);
  }

  final GetDisputeUseCase _getDispute;
  final OpenDisputeUseCase _openDispute;
  final RespondToDisputeUseCase _respondToDispute;

  Future<void> _onLoad(
      LoadDisputeEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoadingState());
    final result =
        await _getDispute(GetDisputeParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(DisputeErrorState(failure: f)),
      (d) => emit(DisputeLoadedState(dispute: d)),
    );
  }

  Future<void> _onOpen(
      OpenDisputeSubmitEvent event, Emitter<DisputeState> emit) async {
    if (state is! DisputeLoadedState) return;
    final current = state as DisputeLoadedState;
    emit(current.copyWith(isActioning: true));
    final result = await _openDispute(OpenDisputeParams(
      bookingId: event.bookingId,
      reason: event.reason,
      description: event.description,
    ));
    result.fold(
      (f) => emit(current.copyWith(actionError: f)),
      (d) => emit(DisputeLoadedState(dispute: d, actionSuccess: true)),
    );
  }

  Future<void> _onRespond(
      RespondToDisputeSubmitEvent event, Emitter<DisputeState> emit) async {
    if (state is! DisputeLoadedState) return;
    final current = state as DisputeLoadedState;
    emit(current.copyWith(isActioning: true));
    final result = await _respondToDispute(RespondToDisputeParams(
      disputeId: event.disputeId,
      response: event.response,
    ));
    result.fold(
      (f) => emit(current.copyWith(actionError: f)),
      (d) => emit(DisputeLoadedState(dispute: d, actionSuccess: true)),
    );
  }
}
