part of 'reschedule_bloc.dart';

sealed class RescheduleState extends Equatable {
  const RescheduleState();
}

class RescheduleIdleState extends RescheduleState {
  const RescheduleIdleState();
  @override
  List<Object?> get props => [];
}

class RescheduleSubmittingState extends RescheduleState {
  const RescheduleSubmittingState();
  @override
  List<Object?> get props => [];
}

class RescheduleSuccessState extends RescheduleState {
  const RescheduleSuccessState({required this.reschedule});
  final BookingRescheduleEntity reschedule;
  @override
  List<Object?> get props => [reschedule];
}

class RescheduleErrorState extends RescheduleState {
  const RescheduleErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
