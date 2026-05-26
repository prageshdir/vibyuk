import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_milestone_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/milestones/approve_milestone_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/milestones/get_milestones_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/milestones/submit_milestone_use_case.dart';

part 'milestone_event.dart';
part 'milestone_state.dart';

class MilestoneBloc extends BaseBloc<MilestoneEvent, MilestoneState> {
  MilestoneBloc({
    required GetMilestonesUseCase getMilestones,
    required SubmitMilestoneUseCase submitMilestone,
    required ApproveMilestoneUseCase approveMilestone,
    required RejectMilestoneUseCase rejectMilestone,
  })  : _getMilestones = getMilestones,
        _submitMilestone = submitMilestone,
        _approveMilestone = approveMilestone,
        _rejectMilestone = rejectMilestone,
        super(const MilestoneInitialState()) {
    on<LoadMilestonesEvent>(_onLoad);
    on<SubmitMilestoneDeliverableEvent>(_onSubmit);
    on<ApproveMilestoneDeliverableEvent>(_onApprove);
    on<RejectMilestoneDeliverableEvent>(_onReject);
  }

  final GetMilestonesUseCase _getMilestones;
  final SubmitMilestoneUseCase _submitMilestone;
  final ApproveMilestoneUseCase _approveMilestone;
  final RejectMilestoneUseCase _rejectMilestone;

  Future<void> _onLoad(
      LoadMilestonesEvent event, Emitter<MilestoneState> emit) async {
    emit(const MilestoneLoadingState());
    final result =
        await _getMilestones(GetMilestonesParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(MilestoneErrorState(failure: f)),
      (ms) => emit(MilestoneLoadedState(milestones: ms)),
    );
  }

  Future<void> _onSubmit(SubmitMilestoneDeliverableEvent event,
      Emitter<MilestoneState> emit) async {
    if (state is! MilestoneLoadedState) return;
    final current = state as MilestoneLoadedState;
    emit(current.copyWith(
        isActioning: true, actioningMilestoneId: event.milestoneId));
    final result = await _submitMilestone(SubmitMilestoneParams(
      bookingId: event.bookingId,
      milestoneId: event.milestoneId,
      deliverableUrl: event.deliverableUrl,
      notes: event.notes,
    ));
    result.fold(
      (f) => emit(current.copyWith(actionError: f)),
      (updated) => emit(current.copyWith(
        milestones: current.milestones
            .map((m) => m.id == updated.id ? updated : m)
            .toList(),
      )),
    );
  }

  Future<void> _onApprove(ApproveMilestoneDeliverableEvent event,
      Emitter<MilestoneState> emit) async {
    if (state is! MilestoneLoadedState) return;
    final current = state as MilestoneLoadedState;
    emit(current.copyWith(
        isActioning: true, actioningMilestoneId: event.milestoneId));
    final result = await _approveMilestone(MilestoneActionParams(
        bookingId: event.bookingId, milestoneId: event.milestoneId));
    result.fold(
      (f) => emit(current.copyWith(actionError: f)),
      (updated) => emit(current.copyWith(
        milestones: current.milestones
            .map((m) => m.id == updated.id ? updated : m)
            .toList(),
      )),
    );
  }

  Future<void> _onReject(RejectMilestoneDeliverableEvent event,
      Emitter<MilestoneState> emit) async {
    if (state is! MilestoneLoadedState) return;
    final current = state as MilestoneLoadedState;
    emit(current.copyWith(
        isActioning: true, actioningMilestoneId: event.milestoneId));
    final result = await _rejectMilestone(RejectMilestoneParams(
      bookingId: event.bookingId,
      milestoneId: event.milestoneId,
      reason: event.reason,
    ));
    result.fold(
      (f) => emit(current.copyWith(actionError: f)),
      (updated) => emit(current.copyWith(
        milestones: current.milestones
            .map((m) => m.id == updated.id ? updated : m)
            .toList(),
      )),
    );
  }
}
