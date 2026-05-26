import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<ProfileEntity, UpdateProfileParams> {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      bio: params.bio,
      location: params.location,
      website: params.website,
      instagram: params.instagram,
      twitter: params.twitter,
      tiktok: params.tiktok,
      youtube: params.youtube,
      linkedin: params.linkedin,
      companyName: params.companyName,
      industry: params.industry,
      companySize: params.companySize,
      serviceTypes: params.serviceTypes,
      skills: params.skills,
      hourlyRateFrom: params.hourlyRateFrom,
      hourlyRateTo: params.hourlyRateTo,
      availability: params.availability,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? location;
  final String? website;
  final String? instagram;
  final String? twitter;
  final String? tiktok;
  final String? youtube;
  final String? linkedin;
  final String? companyName;
  final String? industry;
  final String? companySize;
  final List<String>? serviceTypes;
  final List<String>? skills;
  final double? hourlyRateFrom;
  final double? hourlyRateTo;
  final String? availability;

  const UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.bio,
    this.location,
    this.website,
    this.instagram,
    this.twitter,
    this.tiktok,
    this.youtube,
    this.linkedin,
    this.companyName,
    this.industry,
    this.companySize,
    this.serviceTypes,
    this.skills,
    this.hourlyRateFrom,
    this.hourlyRateTo,
    this.availability,
  });

  @override
  List<Object?> get props => [
        firstName, lastName, bio, location, website,
        instagram, twitter, tiktok, youtube, linkedin,
        companyName, industry, companySize,
        serviceTypes, skills, hourlyRateFrom, hourlyRateTo, availability,
      ];
}
