import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';
import 'package:vibyuk/features/wedding/domain/usecases/add_budget_item_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_budget_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/update_budget_item_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class BudgetTrackerEvent extends Equatable {
  const BudgetTrackerEvent();
}

final class BudgetTrackerLoadRequested extends BudgetTrackerEvent {
  final String weddingId;
  const BudgetTrackerLoadRequested({required this.weddingId});

  @override
  List<Object?> get props => [weddingId];
}

final class BudgetTrackerItemAdded extends BudgetTrackerEvent {
  final String category;
  final String description;
  final double estimatedAmount;
  final double actualAmount;
  final String? vendorId;
  final String? notes;

  const BudgetTrackerItemAdded({
    required this.category,
    required this.description,
    required this.estimatedAmount,
    this.actualAmount = 0,
    this.vendorId,
    this.notes,
  });

  @override
  List<Object?> get props => [
        category,
        description,
        estimatedAmount,
        actualAmount,
        vendorId,
        notes,
      ];
}

final class BudgetTrackerItemUpdated extends BudgetTrackerEvent {
  final String itemId;
  final String? category;
  final String? description;
  final double? estimatedAmount;
  final double? actualAmount;
  final bool? isPaid;
  final String? notes;

  const BudgetTrackerItemUpdated({
    required this.itemId,
    this.category,
    this.description,
    this.estimatedAmount,
    this.actualAmount,
    this.isPaid,
    this.notes,
  });

  @override
  List<Object?> get props => [
        itemId,
        category,
        description,
        estimatedAmount,
        actualAmount,
        isPaid,
        notes,
      ];
}

final class BudgetTrackerRefreshRequested extends BudgetTrackerEvent {
  const BudgetTrackerRefreshRequested();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class BudgetTrackerState extends Equatable {
  const BudgetTrackerState();
}

final class BudgetTrackerInitial extends BudgetTrackerState {
  const BudgetTrackerInitial();

  @override
  List<Object?> get props => [];
}

final class BudgetTrackerLoading extends BudgetTrackerState {
  const BudgetTrackerLoading();

  @override
  List<Object?> get props => [];
}

final class BudgetTrackerLoaded extends BudgetTrackerState {
  final WeddingBudgetEntity budget;
  final bool isSubmitting;

  const BudgetTrackerLoaded({required this.budget, this.isSubmitting = false});

  BudgetTrackerLoaded copyWith({
    WeddingBudgetEntity? budget,
    bool? isSubmitting,
  }) =>
      BudgetTrackerLoaded(
        budget: budget ?? this.budget,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props => [budget, isSubmitting];
}

final class BudgetTrackerError extends BudgetTrackerState {
  final Failure failure;
  const BudgetTrackerError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class BudgetTrackerBloc
    extends BaseBloc<BudgetTrackerEvent, BudgetTrackerState> {
  BudgetTrackerBloc({
    required GetBudgetUseCase getBudget,
    required AddBudgetItemUseCase addItem,
    required UpdateBudgetItemUseCase updateItem,
  })  : _getBudget = getBudget,
        _addItem = addItem,
        _updateItem = updateItem,
        super(const BudgetTrackerInitial()) {
    on<BudgetTrackerLoadRequested>(_onLoadRequested);
    on<BudgetTrackerItemAdded>(_onItemAdded);
    on<BudgetTrackerItemUpdated>(_onItemUpdated);
    on<BudgetTrackerRefreshRequested>(_onRefreshRequested);
  }

  final GetBudgetUseCase _getBudget;
  final AddBudgetItemUseCase _addItem;
  final UpdateBudgetItemUseCase _updateItem;

  String? _weddingId;

  Future<void> _onLoadRequested(
    BudgetTrackerLoadRequested event,
    Emitter<BudgetTrackerState> emit,
  ) async {
    _weddingId = event.weddingId;
    emit(const BudgetTrackerLoading());
    final result = await _getBudget(WeddingIdParams(event.weddingId));
    result.fold(
      (f) => emit(BudgetTrackerError(failure: f)),
      (budget) => emit(BudgetTrackerLoaded(budget: budget)),
    );
  }

  Future<void> _onItemAdded(
    BudgetTrackerItemAdded event,
    Emitter<BudgetTrackerState> emit,
  ) async {
    final current = state;
    if (current is! BudgetTrackerLoaded || _weddingId == null) return;

    emit(current.copyWith(isSubmitting: true));
    final result = await _addItem(AddBudgetItemParams(
      weddingId: _weddingId!,
      category: event.category,
      description: event.description,
      estimatedAmount: event.estimatedAmount,
      actualAmount: event.actualAmount,
      vendorId: event.vendorId,
      notes: event.notes,
    ));
    result.fold(
      (f) => emit(BudgetTrackerError(failure: f)),
      (budget) => emit(BudgetTrackerLoaded(budget: budget)),
    );
  }

  Future<void> _onItemUpdated(
    BudgetTrackerItemUpdated event,
    Emitter<BudgetTrackerState> emit,
  ) async {
    final current = state;
    if (current is! BudgetTrackerLoaded || _weddingId == null) return;

    emit(current.copyWith(isSubmitting: true));
    final result = await _updateItem(UpdateBudgetItemParams(
      weddingId: _weddingId!,
      itemId: event.itemId,
      category: event.category,
      description: event.description,
      estimatedAmount: event.estimatedAmount,
      actualAmount: event.actualAmount,
      isPaid: event.isPaid,
      notes: event.notes,
    ));
    result.fold(
      (f) => emit(BudgetTrackerError(failure: f)),
      (budget) => emit(BudgetTrackerLoaded(budget: budget)),
    );
  }

  Future<void> _onRefreshRequested(
    BudgetTrackerRefreshRequested event,
    Emitter<BudgetTrackerState> emit,
  ) async {
    final id = _weddingId;
    if (id == null) return;
    final result = await _getBudget(WeddingIdParams(id));
    result.fold(
      (f) => emit(BudgetTrackerError(failure: f)),
      (budget) => emit(BudgetTrackerLoaded(budget: budget)),
    );
  }
}
