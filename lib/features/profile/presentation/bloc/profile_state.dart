part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

final class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

final class ProfileLoadedState extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoadedState({required this.profile});

  @override
  List<Object?> get props => [profile];
}

final class ProfileUpdatingState extends ProfileState {
  final ProfileEntity currentProfile;

  const ProfileUpdatingState({required this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

final class ProfileUpdatedState extends ProfileState {
  final ProfileEntity profile;

  const ProfileUpdatedState({required this.profile});

  @override
  List<Object?> get props => [profile];
}

final class AvatarUploadingState extends ProfileState {
  final ProfileEntity currentProfile;

  const AvatarUploadingState({required this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

final class PasswordChangedState extends ProfileState {
  const PasswordChangedState();
}

final class AccountDeletingState extends ProfileState {
  const AccountDeletingState();
}

final class AccountDeletedState extends ProfileState {
  const AccountDeletedState();
}

final class NotificationSettingsLoadedState extends ProfileState {
  final NotificationSettingsEntity settings;

  const NotificationSettingsLoadedState({required this.settings});

  @override
  List<Object?> get props => [settings];
}

final class NotificationSettingsUpdatedState extends ProfileState {
  final NotificationSettingsEntity settings;

  const NotificationSettingsUpdatedState({required this.settings});

  @override
  List<Object?> get props => [settings];
}

final class ProfileErrorState extends ProfileState {
  final Failure failure;
  final ProfileEntity? currentProfile;

  const ProfileErrorState({required this.failure, this.currentProfile});

  @override
  List<Object?> get props => [failure, currentProfile];
}
