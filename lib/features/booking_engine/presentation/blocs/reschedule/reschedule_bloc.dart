import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_reschedule_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/reschedule/reschedule_use_cases.dart';

part 'reschedule_event.dart';
part 'reschedule_state.dart';

class RescheduleBloc extends BaseBloc<RescheduleEvent, RescheduleState> {
  RescheduleBloc({
    required RequestRescheduleUseCase requestReschedule,
    required RespondToRescheduleUseCase respondToReschedule,
  })  : _requestReschedule = requestReschedule,
        _respondToReschedule = respondToReschedule,
        super(const RescheduleIdleState()) {
    on<RequestRescheduleSubmitEvent>(_onRequest);
    on<RespondToRescheduleSubmitEvent>(_onRespond);
  }

  final RequestRescheduleUseCase _requestReschedule;
  final RespondToRescheduleUseCase _respondToReschedule;

  Future<void> _onRequest(RequestRescheduleSubmitEvent event,
      Emitter<RescheduleState> emit) async {
    emit(const RescheduleSubmittingState());
    final result = await _requestReschedule(RequestRescheduleParams(
      bookingId: event.bookingId,
      newDate: event.newDate,
      reason: event.reason,
    ));
    result.fold(
      (f) => emit(RescheduleErrorState(failure: f)),
      (r) => emit(RescheduleSuccessState(reschedule: r)),
    );
  }

  Future<void> _onRespond(RespondToRescheduleSubmitEvent event,
      Emitter<RescheduleState> emit) async {
    emit(const RescheduleSubmittingState());
    final result =
        await _respondToReschedule(RespondToRescheduleParams(
      rescheduleId: event.rescheduleId,
      accept: event.accept,
      declineReason: event.declineReason,
    ));
    result.fold(
      (f) => emit(RescheduleErrorState(failure: f)),
      (r) => emit(RescheduleSuccessState(reschedule: r)),
    );
  }
}
