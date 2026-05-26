import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/onboarding/complete_onboarding_step_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/profile/get_creator_profile_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/profile/get_public_creator_profile_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/profile/update_creator_profile_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/profile/upload_profile_image_use_case.dart';

part 'creator_profile_event.dart';
part 'creator_profile_state.dart';

class CreatorProfileBloc
    extends BaseBloc<CreatorProfileEvent, CreatorProfileState> {
  CreatorProfileBloc({
    required GetCreatorProfileUseCase getProfile,
    required GetPublicCreatorProfileUseCase getPublicProfile,
    required UpdateCreatorProfileUseCase updateProfile,
    required UploadProfileImageUseCase uploadProfileImage,
    required UploadCoverImageUseCase uploadCoverImage,
    required CompleteOnboardingStepUseCase completeOnboardingStep,
  })  : _getProfile = getProfile,
        _getPublicProfile = getPublicProfile,
        _updateProfile = updateProfile,
        _uploadProfileImage = uploadProfileImage,
        _uploadCoverImage = uploadCoverImage,
        _completeOnboardingStep = completeOnboardingStep,
        super(const CreatorProfileInitialState()) {
    on<LoadCreatorProfileEvent>(_onLoad);
    on<LoadPublicCreatorProfileEvent>(_onLoadPublic);
    on<UpdateCreatorProfileEvent>(_onUpdate);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<UploadCoverImageEvent>(_onUploadCoverImage);
    on<CompleteOnboardingStepEvent>(_onCompleteStep);
  }

  final GetCreatorProfileUseCase _getProfile;
  final GetPublicCreatorProfileUseCase _getPublicProfile;
  final UpdateCreatorProfileUseCase _updateProfile;
  final UploadProfileImageUseCase _uploadProfileImage;
  final UploadCoverImageUseCase _uploadCoverImage;
  final CompleteOnboardingStepUseCase _completeOnboardingStep;

  Future<void> _onLoad(
      LoadCreatorProfileEvent event, Emitter<CreatorProfileState> emit) async {
    emit(const CreatorProfileLoadingState());
    final result = await _getProfile(NoParams());
    result.fold(
      (f) => emit(CreatorProfileErrorState(failure: f)),
      (p) => emit(CreatorProfileLoadedState(profile: p)),
    );
  }

  Future<void> _onLoadPublic(LoadPublicCreatorProfileEvent event,
      Emitter<CreatorProfileState> emit) async {
    emit(const CreatorProfileLoadingState());
    final result = await _getPublicProfile(
        GetPublicCreatorProfileParams(creatorId: event.creatorId));
    result.fold(
      (f) => emit(CreatorProfileErrorState(failure: f)),
      (p) => emit(CreatorProfileLoadedState(profile: p)),
    );
  }

  Future<void> _onUpdate(UpdateCreatorProfileEvent event,
      Emitter<CreatorProfileState> emit) async {
    if (state is! CreatorProfileLoadedState) return;
    final current = (state as CreatorProfileLoadedState).profile;
    emit(CreatorProfileUpdatingState(profile: current));
    final result = await _updateProfile(UpdateCreatorProfileParams(
      displayName: event.displayName,
      bio: event.bio,
      location: event.location,
      website: event.website,
      categories: event.categories,
      skills: event.skills,
      languagesSpoken: event.languagesSpoken,
      socialLinks: event.socialLinks,
    ));
    result.fold(
      (f) => emit(CreatorProfileLoadedState(profile: current, updateError: f)),
      (p) => emit(CreatorProfileLoadedState(profile: p, updateSuccess: true)),
    );
  }

  Future<void> _onUploadProfileImage(UploadProfileImageEvent event,
      Emitter<CreatorProfileState> emit) async {
    if (state is! CreatorProfileLoadedState) return;
    final current = (state as CreatorProfileLoadedState).profile;
    emit(CreatorProfileUpdatingState(profile: current));
    final result =
        await _uploadProfileImage(UploadImageParams(filePath: event.filePath));
    result.fold(
      (f) => emit(CreatorProfileLoadedState(profile: current, updateError: f)),
      (_) async {
        final refreshed = await _getProfile(NoParams());
        refreshed.fold(
          (f) => emit(CreatorProfileLoadedState(profile: current)),
          (p) => emit(CreatorProfileLoadedState(profile: p, updateSuccess: true)),
        );
      },
    );
  }

  Future<void> _onUploadCoverImage(UploadCoverImageEvent event,
      Emitter<CreatorProfileState> emit) async {
    if (state is! CreatorProfileLoadedState) return;
    final current = (state as CreatorProfileLoadedState).profile;
    emit(CreatorProfileUpdatingState(profile: current));
    final result =
        await _uploadCoverImage(UploadImageParams(filePath: event.filePath));
    result.fold(
      (f) => emit(CreatorProfileLoadedState(profile: current, updateError: f)),
      (_) async {
        final refreshed = await _getProfile(NoParams());
        refreshed.fold(
          (f) => emit(CreatorProfileLoadedState(profile: current)),
          (p) => emit(CreatorProfileLoadedState(profile: p, updateSuccess: true)),
        );
      },
    );
  }

  Future<void> _onCompleteStep(CompleteOnboardingStepEvent event,
      Emitter<CreatorProfileState> emit) async {
    final result = await _completeOnboardingStep(
        CompleteOnboardingStepParams(step: event.step));
    result.fold(
      (f) => null,
      (p) {
        if (state is CreatorProfileLoadedState) {
          emit(CreatorProfileLoadedState(profile: p));
        }
      },
    );
  }
}
