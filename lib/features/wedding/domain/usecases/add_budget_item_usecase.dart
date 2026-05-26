import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class AddBudgetItemUseCase
    extends UseCase<WeddingBudgetEntity, AddBudgetItemParams> {
  const AddBudgetItemUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingBudgetEntity>> call(
    AddBudgetItemParams params,
  ) {
    final data = <String, dynamic>{
      'category': params.category,
      'description': params.description,
      'estimated_amount': params.estimatedAmount,
      'actual_amount': params.actualAmount,
      if (params.vendorId != null) 'vendor_id': params.vendorId,
      if (params.notes != null) 'notes': params.notes,
    };
    return _repository.addBudgetItem(params.weddingId, data);
  }
}

class AddBudgetItemParams extends Equatable {
  const AddBudgetItemParams({
    required this.weddingId,
    required this.category,
    required this.description,
    required this.estimatedAmount,
    this.actualAmount = 0.0,
    this.vendorId,
    this.notes,
  });

  final String weddingId;
  final String category;
  final String description;
  final double estimatedAmount;
  final double actualAmount;
  final String? vendorId;
  final String? notes;

  @override
  List<Object?> get props => [
        weddingId,
        category,
        description,
        estimatedAmount,
        actualAmount,
        vendorId,
        notes,
      ];
}
