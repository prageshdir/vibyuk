import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/entities/notification_settings_entity.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';
import 'package:vibyuk/features/profile/domain/usecases/change_password_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/delete_account_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/get_my_profile_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/get_notification_settings_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/update_notification_settings_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/upload_avatar_use_case.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends BaseBloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetMyProfileUseCase getMyProfile,
    required UpdateProfileUseCase updateProfile,
    required UploadAvatarUseCase uploadAvatar,
    required ChangePasswordUseCase changePassword,
    required DeleteAccountUseCase deleteAccount,
    required GetNotificationSettingsUseCase getNotificationSettings,
    required UpdateNotificationSettingsUseCase updateNotificationSettings,
  })  : _getMyProfile = getMyProfile,
        _updateProfile = updateProfile,
        _uploadAvatar = uploadAvatar,
        _changePassword = changePassword,
        _deleteAccount = deleteAccount,
        _getNotificationSettings = getNotificationSettings,
        _updateNotificationSettings = updateNotificationSettings,
        super(const ProfileInitialState()) {
    on<LoadMyProfileEvent>(_onLoadMyProfile);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<LoadNotificationSettingsEvent>(_onLoadNotificationSettings);
    on<UpdateNotificationSettingsEvent>(_onUpdateNotificationSettings);
    on<ProfileErrorClearedEvent>(_onErrorCleared);
  }

  final GetMyProfileUseCase _getMyProfile;
  final UpdateProfileUseCase _updateProfile;
  final UploadAvatarUseCase _uploadAvatar;
  final ChangePasswordUseCase _changePassword;
  final DeleteAccountUseCase _deleteAccount;
  final GetNotificationSettingsUseCase _getNotificationSettings;
  final UpdateNotificationSettingsUseCase _updateNotificationSettings;

  ProfileEntity? _cachedProfile;

  Future<void> _onLoadMyProfile(
    LoadMyProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    final result = await _getMyProfile();
    result.fold(
      (failure) => emit(ProfileErrorState(failure: failure)),
      (profile) {
        _cachedProfile = profile;
        emit(ProfileLoadedState(profile: profile));
      },
    );
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _getMyProfile();
    result.fold(
      (failure) => emit(
        ProfileErrorState(failure: failure, currentProfile: _cachedProfile),
      ),
      (profile) {
        _cachedProfile = profile;
        emit(ProfileLoadedState(profile: profile));
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (_cachedProfile != null) {
      emit(ProfileUpdatingState(currentProfile: _cachedProfile!));
    }

    final result = await _updateProfile(event.params);
    result.fold(
      (failure) => emit(
        ProfileErrorState(failure: failure, currentProfile: _cachedProfile),
      ),
      (profile) {
        _cachedProfile = profile;
        emit(ProfileUpdatedState(profile: profile));
      },
    );
  }

  Future<void> _onUploadAvatar(
    UploadAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (_cachedProfile != null) {
      emit(AvatarUploadingState(currentProfile: _cachedProfile!));
    }

    final result = await _uploadAvatar(UploadAvatarParams(filePath: event.filePath));
    await result.fold(
      (failure) async => emit(
        ProfileErrorState(failure: failure, currentProfile: _cachedProfile),
      ),
      (_) async {
        // Reload profile to get updated avatar URL
        final profileResult = await _getMyProfile();
        profileResult.fold(
          (failure) => emit(ProfileErrorState(failure: failure, currentProfile: _cachedProfile)),
          (profile) {
            _cachedProfile = profile;
            emit(ProfileUpdatedState(profile: profile));
          },
        );
      },
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    final result = await _changePassword(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        newPasswordConfirmation: event.newPasswordConfirmation,
      ),
    );
    result.fold(
      (failure) => emit(ProfileErrorState(failure: failure, currentProfile: _cachedProfile)),
      (_) => emit(const PasswordChangedState()),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const AccountDeletingState());
    final result = await _deleteAccount(DeleteAccountParams(password: event.password));
    result.fold(
      (failure) => emit(ProfileErrorState(failure: failure, currentProfile: _cachedProfile)),
      (_) {
        _cachedProfile = null;
        emit(const AccountDeletedState());
      },
    );
  }

  Future<void> _onLoadNotificationSettings(
    LoadNotificationSettingsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _getNotificationSettings();
    result.fold(
      (failure) => emit(
        ProfileErrorState(failure: failure, currentProfile: _cachedProfile),
      ),
      (settings) => emit(NotificationSettingsLoadedState(settings: settings)),
    );
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettingsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _updateNotificationSettings(
      UpdateNotificationSettingsParams(settings: event.settings),
    );
    result.fold(
      (failure) => emit(
        ProfileErrorState(failure: failure, currentProfile: _cachedProfile),
      ),
      (settings) => emit(NotificationSettingsUpdatedState(settings: settings)),
    );
  }

  void _onErrorCleared(
    ProfileErrorClearedEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (_cachedProfile != null) {
      emit(ProfileLoadedState(profile: _cachedProfile!));
    } else {
      emit(const ProfileInitialState());
    }
  }
}
