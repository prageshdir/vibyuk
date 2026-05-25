part of 'transaction_bloc.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();
}

class TransactionInitialState extends TransactionState {
  const TransactionInitialState();
  @override
  List<Object?> get props => [];
}

class TransactionLoadingState extends TransactionState {
  const TransactionLoadingState();
  @override
  List<Object?> get props => [];
}

class TransactionsLoadedState extends TransactionState {
  const TransactionsLoadedState({
    required this.transactions,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.typeFilter,
  });

  final List<TransactionEntity> transactions;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final TransactionType? typeFilter;

  TransactionsLoadedState copyWith({
    List<TransactionEntity>? transactions,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    TransactionType? typeFilter,
    bool clearFilter = false,
  }) =>
      TransactionsLoadedState(
        transactions: transactions ?? this.transactions,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        typeFilter: clearFilter ? null : (typeFilter ?? this.typeFilter),
      );

  @override
  List<Object?> get props => [
        transactions,
        hasMore,
        currentPage,
        isLoadingMore,
        typeFilter,
      ];
}

class TransactionErrorState extends TransactionState {
  const TransactionErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
