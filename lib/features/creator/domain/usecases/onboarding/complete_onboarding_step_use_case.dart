import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class CompleteOnboardingStepUseCase
    extends UseCase<CreatorProfileEntity, CompleteOnboardingStepParams> {
  final CreatorRepository _repository;
  const CompleteOnboardingStepUseCase(this._repository);

  @override
  Future<Either<Failure, CreatorProfileEntity>> call(
      CompleteOnboardingStepParams params) =>
      _repository.completeOnboardingStep(step: params.step);
}

class CompleteOnboardingStepParams extends Equatable {
  final OnboardingStep step;
  const CompleteOnboardingStepParams({required this.step});

  @override
  List<Object?> get props => [step];
}
