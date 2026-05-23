part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class LoadMyProfileEvent extends ProfileEvent {
  const LoadMyProfileEvent();
}

final class RefreshProfileEvent extends ProfileEvent {
  const RefreshProfileEvent();
}

final class UpdateProfileEvent extends ProfileEvent {
  final UpdateProfileParams params;

  const UpdateProfileEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

final class UploadAvatarEvent extends ProfileEvent {
  final String filePath;

  const UploadAvatarEvent({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

final class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, newPasswordConfirmation];
}

final class DeleteAccountEvent extends ProfileEvent {
  final String password;

  const DeleteAccountEvent({required this.password});

  @override
  List<Object?> get props => [password];
}

final class LoadNotificationSettingsEvent extends ProfileEvent {
  const LoadNotificationSettingsEvent();
}

final class UpdateNotificationSettingsEvent extends ProfileEvent {
  final NotificationSettingsEntity settings;

  const UpdateNotificationSettingsEvent({required this.settings});

  @override
  List<Object?> get props => [settings];
}

final class ProfileErrorClearedEvent extends ProfileEvent {
  const ProfileErrorClearedEvent();
}
