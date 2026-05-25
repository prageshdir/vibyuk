import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class UpdateBudgetItemUseCase
    extends UseCase<WeddingBudgetEntity, UpdateBudgetItemParams> {
  const UpdateBudgetItemUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingBudgetEntity>> call(
    UpdateBudgetItemParams params,
  ) {
    final data = <String, dynamic>{
      if (params.category != null) 'category': params.category,
      if (params.description != null) 'description': params.description,
      if (params.estimatedAmount != null)
        'estimated_amount': params.estimatedAmount,
      if (params.actualAmount != null) 'actual_amount': params.actualAmount,
      if (params.isPaid != null) 'is_paid': params.isPaid,
      if (params.notes != null) 'notes': params.notes,
    };
    return _repository.updateBudgetItem(params.weddingId, params.itemId, data);
  }
}

class UpdateBudgetItemParams extends Equatable {
  const UpdateBudgetItemParams({
    required this.weddingId,
    required this.itemId,
    this.category,
    this.description,
    this.estimatedAmount,
    this.actualAmount,
    this.isPaid,
    this.notes,
  });

  final String weddingId;
  final String itemId;
  final String? category;
  final String? description;
  final double? estimatedAmount;
  final double? actualAmount;
  final bool? isPaid;
  final String? notes;

  @override
  List<Object?> get props => [
        weddingId,
        itemId,
        category,
        description,
        estimatedAmount,
        actualAmount,
        isPaid,
        notes,
      ];
}
