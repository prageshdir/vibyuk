import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class ApplyForFamTripUseCase implements UseCase<Unit, ApplyFamTripParams> {
  const ApplyForFamTripUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ApplyFamTripParams params) {
    return _repository.applyForFamTrip(params.tripId, params.toMap());
  }
}

class ApplyFamTripParams extends Equatable {
  const ApplyFamTripParams({
    required this.tripId,
    required this.creatorBio,
    required this.followersCount,
    required this.niches,
    this.portfolioUrls = const [],
    this.motivation,
  });

  final String tripId;
  final String creatorBio;
  final int followersCount;
  final List<String> niches;
  final List<String> portfolioUrls;
  final String? motivation;

  Map<String, dynamic> toMap() => {
        'creator_bio': creatorBio,
        'followers_count': followersCount,
        'niches': niches,
        'portfolio_urls': portfolioUrls,
        if (motivation != null) 'motivation': motivation,
      };

  @override
  List<Object?> get props =>
      [tripId, creatorBio, followersCount, niches, portfolioUrls, motivation];
}
