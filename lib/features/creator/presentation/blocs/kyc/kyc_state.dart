part of 'kyc_bloc.dart';

sealed class KycState extends Equatable {
  const KycState();
}

class KycInitialState extends KycState {
  const KycInitialState();
  @override
  List<Object?> get props => [];
}

class KycLoadingState extends KycState {
  const KycLoadingState();
  @override
  List<Object?> get props => [];
}

class KycLoadedState extends KycState {
  const KycLoadedState({
    required this.kyc,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
  });
  final KycEntity kyc;
  final bool isSubmitting;
  final Failure? submitError;
  final bool submitSuccess;

  KycLoadedState copyWith({
    KycEntity? kyc,
    bool? isSubmitting,
    Failure? submitError,
    bool? submitSuccess,
  }) =>
      KycLoadedState(
        kyc: kyc ?? this.kyc,
        isSubmitting: isSubmitting ?? false,
        submitError: submitError,
        submitSuccess: submitSuccess ?? false,
      );

  @override
  List<Object?> get props => [kyc, isSubmitting, submitError, submitSuccess];
}

class KycErrorState extends KycState {
  const KycErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
