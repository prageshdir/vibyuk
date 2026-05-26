import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class UpdateCreatorProfileUseCase
    extends UseCase<CreatorProfileEntity, UpdateCreatorProfileParams> {
  final CreatorRepository _repository;
  const UpdateCreatorProfileUseCase(this._repository);

  @override
  Future<Either<Failure, CreatorProfileEntity>> call(
          UpdateCreatorProfileParams params) =>
      _repository.updateProfile(
        displayName: params.displayName,
        bio: params.bio,
        location: params.location,
        website: params.website,
        categories: params.categories,
        skills: params.skills,
        socialLinks: params.socialLinks,
      );
}

class UpdateCreatorProfileParams extends Equatable {
  final String displayName;
  final String? bio;
  final String? location;
  final String? website;
  final List<String>? categories;
  final List<String>? skills;
  final List<SocialLinkEntity>? socialLinks;

  const UpdateCreatorProfileParams({
    required this.displayName,
    this.bio,
    this.location,
    this.website,
    this.categories,
    this.skills,
    this.socialLinks,
  });

  @override
  List<Object?> get props =>
      [displayName, bio, location, website, categories, skills, socialLinks];
}
