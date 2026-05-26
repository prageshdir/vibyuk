part of 'dispute_bloc.dart';

sealed class DisputeState extends Equatable {
  const DisputeState();
}

class DisputeInitialState extends DisputeState {
  const DisputeInitialState();
  @override
  List<Object?> get props => [];
}

class DisputeLoadingState extends DisputeState {
  const DisputeLoadingState();
  @override
  List<Object?> get props => [];
}

class DisputeLoadedState extends DisputeState {
  const DisputeLoadedState({
    this.dispute,
    this.isActioning = false,
    this.actionError,
    this.actionSuccess = false,
  });

  final BookingDisputeEntity? dispute;
  final bool isActioning;
  final Failure? actionError;
  final bool actionSuccess;

  bool get hasDispute => dispute != null;

  DisputeLoadedState copyWith({
    BookingDisputeEntity? dispute,
    bool clearDispute = false,
    bool? isActioning,
    Failure? actionError,
    bool? actionSuccess,
  }) =>
      DisputeLoadedState(
        dispute: clearDispute ? null : (dispute ?? this.dispute),
        isActioning: isActioning ?? false,
        actionError: actionError,
        actionSuccess: actionSuccess ?? false,
      );

  @override
  List<Object?> get props => [dispute, isActioning, actionError, actionSuccess];
}

class DisputeErrorState extends DisputeState {
  const DisputeErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
