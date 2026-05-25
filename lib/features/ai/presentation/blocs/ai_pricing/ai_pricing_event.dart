import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';

abstract class AiPricingEvent extends Equatable {
  const AiPricingEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllPricingSuggestions extends AiPricingEvent {
  const LoadAllPricingSuggestions();
}

class GetPricingSuggestion extends AiPricingEvent {
  final PricingServiceType serviceType;
  final String location;
  final int experienceYears;
  final Map<String, dynamic>? additionalFactors;

  const GetPricingSuggestion({
    required this.serviceType,
    required this.location,
    required this.experienceYears,
    this.additionalFactors,
  });

  @override
  List<Object?> get props =>
      [serviceType, location, experienceYears, additionalFactors];
}

class SelectServiceType extends AiPricingEvent {
  final PricingServiceType serviceType;

  const SelectServiceType({required this.serviceType});

  @override
  List<Object?> get props => [serviceType];
}
