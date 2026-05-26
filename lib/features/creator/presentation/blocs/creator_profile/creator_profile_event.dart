part of 'creator_profile_bloc.dart';

sealed class CreatorProfileEvent extends Equatable {
  const CreatorProfileEvent();
}

class LoadCreatorProfileEvent extends CreatorProfileEvent {
  const LoadCreatorProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadPublicCreatorProfileEvent extends CreatorProfileEvent {
  const LoadPublicCreatorProfileEvent({required this.creatorId});
  final String creatorId;
  @override
  List<Object?> get props => [creatorId];
}

class UpdateCreatorProfileEvent extends CreatorProfileEvent {
  const UpdateCreatorProfileEvent({
    required this.displayName,
    this.bio,
    this.location,
    this.website,
    this.categories,
    this.skills,
    this.languagesSpoken,
    this.socialLinks,
  });
  final String displayName;
  final String? bio;
  final String? location;
  final String? website;
  final List<String>? categories;
  final List<String>? skills;
  final List<String>? languagesSpoken;
  final List<SocialLinkEntity>? socialLinks;
  @override
  List<Object?> get props =>
      [displayName, bio, location, website, categories, skills, languagesSpoken, socialLinks];
}

class UploadProfileImageEvent extends CreatorProfileEvent {
  const UploadProfileImageEvent({required this.filePath});
  final String filePath;
  @override
  List<Object?> get props => [filePath];
}

class UploadCoverImageEvent extends CreatorProfileEvent {
  const UploadCoverImageEvent({required this.filePath});
  final String filePath;
  @override
  List<Object?> get props => [filePath];
}

class CompleteOnboardingStepEvent extends CreatorProfileEvent {
  const CompleteOnboardingStepEvent({required this.step});
  final OnboardingStep step;
  @override
  List<Object?> get props => [step];
}
