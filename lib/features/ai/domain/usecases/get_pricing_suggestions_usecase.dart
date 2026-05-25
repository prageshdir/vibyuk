import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';
import 'package:vibyuk/features/ai/domain/repositories/ai_repository.dart';

class GetPricingSuggestionUseCase
    implements UseCase<AiPricingSuggestion, PricingParams> {
  final AiRepository _repository;

  const GetPricingSuggestionUseCase(this._repository);

  @override
  Future<Either<Failure, AiPricingSuggestion>> call(PricingParams params) {
    return _repository.getPricingSuggestion(
      serviceType: params.serviceType,
      location: params.location,
      experienceYears: params.experienceYears,
      additionalFactors: params.additionalFactors,
    );
  }
}

class GetAllPricingSuggestionsUseCase
    implements NoParamUseCase<List<AiPricingSuggestion>> {
  final AiRepository _repository;

  const GetAllPricingSuggestionsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AiPricingSuggestion>>> call() {
    return _repository.getAllPricingSuggestions();
  }
}

class PricingParams extends Equatable {
  final PricingServiceType serviceType;
  final String location;
  final int experienceYears;
  final Map<String, dynamic>? additionalFactors;

  const PricingParams({
    required this.serviceType,
    required this.location,
    required this.experienceYears,
    this.additionalFactors,
  });

  @override
  List<Object?> get props => [serviceType, location, experienceYears, additionalFactors];
}
