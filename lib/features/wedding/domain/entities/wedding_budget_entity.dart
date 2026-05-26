import 'package:equatable/equatable.dart';

class WeddingBudgetItemEntity extends Equatable {
  const WeddingBudgetItemEntity({
    required this.id,
    required this.weddingId,
    required this.category,
    required this.description,
    required this.estimatedAmount,
    required this.actualAmount,
    required this.isPaid,
    this.vendorId,
    this.notes,
  });

  final String id;
  final String weddingId;
  final String category;
  final String description;
  final double estimatedAmount;
  final double actualAmount;
  final bool isPaid;
  final String? vendorId;
  final String? notes;

  double get variance => actualAmount - estimatedAmount;
  bool get isOverBudget => actualAmount > estimatedAmount;

  @override
  List<Object?> get props => [
        id,
        weddingId,
        category,
        description,
        estimatedAmount,
        actualAmount,
        isPaid,
        vendorId,
        notes,
      ];
}

class WeddingBudgetEntity extends Equatable {
  const WeddingBudgetEntity({
    required this.weddingId,
    required this.totalBudget,
    required this.items,
  });

  final String weddingId;
  final double totalBudget;
  final List<WeddingBudgetItemEntity> items;

  double get totalEstimated =>
      items.fold(0.0, (sum, i) => sum + i.estimatedAmount);

  double get totalActual =>
      items.fold(0.0, (sum, i) => sum + i.actualAmount);

  double get remainingBudget => totalBudget - totalActual;

  double get spentPercentage =>
      totalBudget > 0 ? (totalActual / totalBudget * 100).clamp(0, 100) : 0;

  Map<String, double> get actualByCategory {
    final map = <String, double>{};
    for (final item in items) {
      map[item.category] = (map[item.category] ?? 0) + item.actualAmount;
    }
    return map;
  }

  @override
  List<Object?> get props => [weddingId, totalBudget, items];
}
