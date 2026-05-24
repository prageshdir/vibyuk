part of 'pricing_bloc.dart';

sealed class PricingState extends Equatable {
  const PricingState();
}

class PricingInitialState extends PricingState {
  const PricingInitialState();
  @override
  List<Object?> get props => [];
}

class PricingLoadingState extends PricingState {
  const PricingLoadingState();
  @override
  List<Object?> get props => [];
}

class PricingLoadedState extends PricingState {
  const PricingLoadedState({
    required this.packages,
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
  });
  final List<PricingPackageEntity> packages;
  final bool isSaving;
  final Failure? saveError;
  final bool saveSuccess;

  PricingLoadedState copyWith({
    List<PricingPackageEntity>? packages,
    bool? isSaving,
    Failure? saveError,
    bool? saveSuccess,
  }) =>
      PricingLoadedState(
        packages: packages ?? this.packages,
        isSaving: isSaving ?? false,
        saveError: saveError,
        saveSuccess: saveSuccess ?? false,
      );

  @override
  List<Object?> get props => [packages, isSaving, saveError, saveSuccess];
}

class PricingErrorState extends PricingState {
  const PricingErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
