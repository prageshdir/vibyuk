import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';

class AiPricingFactorModel extends AiPricingFactor {
  const AiPricingFactorModel({
    required super.label,
    required super.impact,
    required super.description,
  });

  factory AiPricingFactorModel.fromJson(Map<String, dynamic> json) {
    return AiPricingFactorModel(
      label: json['label'] as String,
      impact: (json['impact'] as num).toDouble(),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'impact': impact,
        'description': description,
      };
}

class AiMarketComparisonModel extends AiMarketComparison {
  const AiMarketComparisonModel({
    required super.marketLow,
    required super.marketMedian,
    required super.marketHigh,
    required super.percentileRank,
  });

  factory AiMarketComparisonModel.fromJson(Map<String, dynamic> json) {
    return AiMarketComparisonModel(
      marketLow: (json['market_low'] as num).toDouble(),
      marketMedian: (json['market_median'] as num).toDouble(),
      marketHigh: (json['market_high'] as num).toDouble(),
      percentileRank: (json['percentile_rank'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'market_low': marketLow,
        'market_median': marketMedian,
        'market_high': marketHigh,
        'percentile_rank': percentileRank,
      };
}

class AiPricingSuggestionModel extends AiPricingSuggestion {
  const AiPricingSuggestionModel({
    required super.id,
    required super.serviceType,
    required super.suggestedPrice,
    required super.minPrice,
    required super.maxPrice,
    super.currency,
    required super.confidence,
    required super.marketComparison,
    required super.factors,
    required super.recommendation,
    super.creatorId,
    required super.generatedAt,
  });

  factory AiPricingSuggestionModel.fromJson(Map<String, dynamic> json) {
    return AiPricingSuggestionModel(
      id: json['id'] as String,
      serviceType: PricingServiceType.values.firstWhere(
        (e) => e.name == json['service_type'],
        orElse: () => PricingServiceType.photography,
      ),
      suggestedPrice: (json['suggested_price'] as num).toDouble(),
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'GBP',
      confidence: PricingConfidence.values.firstWhere(
        (e) => e.name == json['confidence'],
        orElse: () => PricingConfidence.medium,
      ),
      marketComparison: AiMarketComparisonModel.fromJson(
        json['market_comparison'] as Map<String, dynamic>,
      ),
      factors: (json['factors'] as List)
          .map((f) => AiPricingFactorModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      recommendation: json['recommendation'] as String,
      creatorId: json['creator_id'] as String?,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_type': serviceType.name,
        'suggested_price': suggestedPrice,
        'min_price': minPrice,
        'max_price': maxPrice,
        'currency': currency,
        'confidence': confidence.name,
        'market_comparison':
            (marketComparison as AiMarketComparisonModel).toJson(),
        'factors': (factors as List<AiPricingFactorModel>)
            .map((f) => f.toJson())
            .toList(),
        'recommendation': recommendation,
        'creator_id': creatorId,
        'generated_at': generatedAt.toIso8601String(),
      };
}
