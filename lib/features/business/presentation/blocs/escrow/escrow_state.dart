part of 'escrow_bloc.dart';

sealed class EscrowState extends Equatable {
  const EscrowState();
}

class EscrowInitialState extends EscrowState {
  const EscrowInitialState();
  @override
  List<Object?> get props => [];
}

class EscrowLoadingState extends EscrowState {
  const EscrowLoadingState();
  @override
  List<Object?> get props => [];
}

class EscrowActionInProgressState extends EscrowState {
  const EscrowActionInProgressState();
  @override
  List<Object?> get props => [];
}

class EscrowLoadedState extends EscrowState {
  const EscrowLoadedState({required this.escrow, this.lastActionSuccess});
  final EscrowEntity escrow;
  final String? lastActionSuccess;
  @override
  List<Object?> get props => [escrow, lastActionSuccess];
}

class EscrowErrorState extends EscrowState {
  const EscrowErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
