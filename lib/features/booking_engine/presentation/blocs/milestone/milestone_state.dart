part of 'milestone_bloc.dart';

sealed class MilestoneState extends Equatable {
  const MilestoneState();
}

class MilestoneInitialState extends MilestoneState {
  const MilestoneInitialState();
  @override
  List<Object?> get props => [];
}

class MilestoneLoadingState extends MilestoneState {
  const MilestoneLoadingState();
  @override
  List<Object?> get props => [];
}

class MilestoneLoadedState extends MilestoneState {
  const MilestoneLoadedState({
    required this.milestones,
    this.isActioning = false,
    this.actioningMilestoneId,
    this.actionError,
  });

  final List<BookingMilestoneEntity> milestones;
  final bool isActioning;
  final String? actioningMilestoneId;
  final Failure? actionError;

  MilestoneLoadedState copyWith({
    List<BookingMilestoneEntity>? milestones,
    bool? isActioning,
    String? actioningMilestoneId,
    Failure? actionError,
  }) =>
      MilestoneLoadedState(
        milestones: milestones ?? this.milestones,
        isActioning: isActioning ?? false,
        actioningMilestoneId: actioningMilestoneId,
        actionError: actionError,
      );

  @override
  List<Object?> get props =>
      [milestones, isActioning, actioningMilestoneId, actionError];
}

class MilestoneErrorState extends MilestoneState {
  const MilestoneErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
