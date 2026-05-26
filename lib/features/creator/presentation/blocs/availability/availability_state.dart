part of 'availability_bloc.dart';

sealed class AvailabilityState extends Equatable {
  const AvailabilityState();
}

class AvailabilityInitialState extends AvailabilityState {
  const AvailabilityInitialState();
  @override
  List<Object?> get props => [];
}

class AvailabilityLoadingState extends AvailabilityState {
  const AvailabilityLoadingState();
  @override
  List<Object?> get props => [];
}

class AvailabilityLoadedState extends AvailabilityState {
  const AvailabilityLoadedState({
    required this.availability,
    required this.visibleMonth,
    this.isSaving = false,
    this.saveSuccess = false,
  });
  final AvailabilityEntity availability;
  final DateTime visibleMonth;
  final bool isSaving;
  final bool saveSuccess;

  AvailabilityLoadedState copyWith({
    AvailabilityEntity? availability,
    DateTime? visibleMonth,
    bool? isSaving,
    bool? saveSuccess,
  }) =>
      AvailabilityLoadedState(
        availability: availability ?? this.availability,
        visibleMonth: visibleMonth ?? this.visibleMonth,
        isSaving: isSaving ?? false,
        saveSuccess: saveSuccess ?? false,
      );

  @override
  List<Object?> get props => [availability, visibleMonth, isSaving, saveSuccess];
}

class AvailabilityErrorState extends AvailabilityState {
  const AvailabilityErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
