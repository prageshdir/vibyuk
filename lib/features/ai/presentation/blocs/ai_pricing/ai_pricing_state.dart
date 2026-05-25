import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';

enum AiPricingStatus { initial, loading, success, failure }

class AiPricingState extends Equatable {
  final AiPricingStatus status;
  final List<AiPricingSuggestion> suggestions;
  final AiPricingSuggestion? activeSuggestion;
  final PricingServiceType? selectedServiceType;
  final Failure? failure;

  const AiPricingState({
    this.status = AiPricingStatus.initial,
    this.suggestions = const [],
    this.activeSuggestion,
    this.selectedServiceType,
    this.failure,
  });

  bool get isLoading => status == AiPricingStatus.loading;
  bool get hasData => suggestions.isNotEmpty;
  bool get hasError => status == AiPricingStatus.failure;

  AiPricingState copyWith({
    AiPricingStatus? status,
    List<AiPricingSuggestion>? suggestions,
    AiPricingSuggestion? activeSuggestion,
    PricingServiceType? selectedServiceType,
    Failure? failure,
  }) {
    return AiPricingState(
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      activeSuggestion: activeSuggestion ?? this.activeSuggestion,
      selectedServiceType: selectedServiceType ?? this.selectedServiceType,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props =>
      [status, suggestions, activeSuggestion, selectedServiceType, failure];
}
