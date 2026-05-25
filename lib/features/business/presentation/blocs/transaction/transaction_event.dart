part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();
}

class LoadTransactionsEvent extends TransactionEvent {
  const LoadTransactionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMoreTransactionsEvent extends TransactionEvent {
  const LoadMoreTransactionsEvent();
  @override
  List<Object?> get props => [];
}

class FilterTransactionsByTypeEvent extends TransactionEvent {
  const FilterTransactionsByTypeEvent(this.type);
  final TransactionType? type;
  @override
  List<Object?> get props => [type];
}
