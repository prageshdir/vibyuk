import 'package:equatable/equatable.dart';

enum PricingConfidence { low, medium, high, veryHigh }
enum PricingServiceType {
  photography,
  videography,
  musicPerformance,
  djSet,
  eventPlanning,
  speaking,
  brandDesign,
  socialContent,
}

class AiPricingFactor extends Equatable {
  final String label;
  final double impact;
  final String description;

  const AiPricingFactor({
    required this.label,
    required this.impact,
    required this.description,
  });

  @override
  List<Object?> get props => [label, impact, description];
}

class AiMarketComparison extends Equatable {
  final double marketLow;
  final double marketMedian;
  final double marketHigh;
  final double percentileRank;

  const AiMarketComparison({
    required this.marketLow,
    required this.marketMedian,
    required this.marketHigh,
    required this.percentileRank,
  });

  @override
  List<Object?> get props => [marketLow, marketMedian, marketHigh, percentileRank];
}

class AiPricingSuggestion extends Equatable {
  final String id;
  final PricingServiceType serviceType;
  final double suggestedPrice;
  final double minPrice;
  final double maxPrice;
  final String currency;
  final PricingConfidence confidence;
  final AiMarketComparison marketComparison;
  final List<AiPricingFactor> factors;
  final String recommendation;
  final String? creatorId;
  final DateTime generatedAt;

  const AiPricingSuggestion({
    required this.id,
    required this.serviceType,
    required this.suggestedPrice,
    required this.minPrice,
    required this.maxPrice,
    this.currency = 'GBP',
    required this.confidence,
    required this.marketComparison,
    required this.factors,
    required this.recommendation,
    this.creatorId,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        serviceType,
        suggestedPrice,
        minPrice,
        maxPrice,
        currency,
        confidence,
        marketComparison,
        factors,
        recommendation,
        creatorId,
        generatedAt,
      ];
}
