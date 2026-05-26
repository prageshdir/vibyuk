import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/transaction_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_transactions_use_case.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends BaseBloc<TransactionEvent, TransactionState> {
  TransactionBloc({required GetTransactionsUseCase getTransactions})
      : _getTransactions = getTransactions,
        super(const TransactionInitialState()) {
    on<LoadTransactionsEvent>(_onLoad);
    on<LoadMoreTransactionsEvent>(_onLoadMore);
    on<FilterTransactionsByTypeEvent>(_onFilter);
  }

  final GetTransactionsUseCase _getTransactions;
  TransactionType? _typeFilter;

  Future<void> _onLoad(LoadTransactionsEvent event, Emitter<TransactionState> emit) async {
    emit(const TransactionLoadingState());
    _typeFilter = null;
    final result = await _getTransactions(const GetTransactionsParams());
    result.fold(
      (f) => emit(TransactionErrorState(failure: f)),
      (page) => emit(TransactionsLoadedState(
        transactions: page.items,
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMoreTransactionsEvent event, Emitter<TransactionState> emit) async {
    if (state is! TransactionsLoadedState) return;
    final loaded = state as TransactionsLoadedState;
    if (!loaded.hasMore || loaded.isLoadingMore) return;
    emit(loaded.copyWith(isLoadingMore: true));
    final result = await _getTransactions(
        GetTransactionsParams(page: loaded.currentPage + 1, type: _typeFilter));
    result.fold(
      (f) => emit(loaded.copyWith(isLoadingMore: false)),
      (page) => emit(loaded.copyWith(
        transactions: [...loaded.transactions, ...page.items],
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onFilter(
      FilterTransactionsByTypeEvent event, Emitter<TransactionState> emit) async {
    _typeFilter = event.type;
    emit(const TransactionLoadingState());
    final result = await _getTransactions(GetTransactionsParams(type: event.type));
    result.fold(
      (f) => emit(TransactionErrorState(failure: f)),
      (page) => emit(TransactionsLoadedState(
        transactions: page.items,
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        typeFilter: event.type,
      )),
    );
  }
}
