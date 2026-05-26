import 'package:equatable/equatable.dart';

class WeddingAnalyticsEntity extends Equatable {
  const WeddingAnalyticsEntity({
    required this.weddingId,
    required this.totalBudget,
    required this.budgetUsed,
    required this.vendorsBooked,
    required this.vendorsPending,
    required this.timelineCompletionRate,
    required this.daysUntilWedding,
    required this.guestConfirmationRate,
    required this.topExpenseCategory,
    required this.budgetByCategory,
  });

  final String weddingId;
  final double totalBudget;
  final double budgetUsed;
  final int vendorsBooked;
  final int vendorsPending;
  final double timelineCompletionRate;
  final int daysUntilWedding;
  final double guestConfirmationRate;
  final String topExpenseCategory;
  final Map<String, double> budgetByCategory;

  double get budgetUsedPercentage =>
      totalBudget > 0 ? (budgetUsed / totalBudget * 100).clamp(0, 100) : 0;

  double get budgetRemaining => totalBudget - budgetUsed;

  int get totalVendors => vendorsBooked + vendorsPending;

  @override
  List<Object?> get props => [
        weddingId,
        totalBudget,
        budgetUsed,
        vendorsBooked,
        vendorsPending,
        timelineCompletionRate,
        daysUntilWedding,
        guestConfirmationRate,
        topExpenseCategory,
        budgetByCategory,
      ];
}
