part of 'creator_profile_bloc.dart';

sealed class CreatorProfileState extends Equatable {
  const CreatorProfileState();
}

class CreatorProfileInitialState extends CreatorProfileState {
  const CreatorProfileInitialState();
  @override
  List<Object?> get props => [];
}

class CreatorProfileLoadingState extends CreatorProfileState {
  const CreatorProfileLoadingState();
  @override
  List<Object?> get props => [];
}

class CreatorProfileLoadedState extends CreatorProfileState {
  const CreatorProfileLoadedState({
    required this.profile,
    this.updateError,
    this.updateSuccess = false,
  });
  final CreatorProfileEntity profile;
  final Failure? updateError;
  final bool updateSuccess;
  @override
  List<Object?> get props => [profile, updateError, updateSuccess];
}

class CreatorProfileUpdatingState extends CreatorProfileState {
  const CreatorProfileUpdatingState({required this.profile});
  final CreatorProfileEntity profile;
  @override
  List<Object?> get props => [profile];
}

class CreatorProfileErrorState extends CreatorProfileState {
  const CreatorProfileErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
