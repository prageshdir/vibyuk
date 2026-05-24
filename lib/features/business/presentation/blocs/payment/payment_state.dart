part of 'payment_bloc.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();
}

class PaymentInitialState extends PaymentState {
  const PaymentInitialState();
  @override
  List<Object?> get props => [];
}

class PaymentLoadingState extends PaymentState {
  const PaymentLoadingState();
  @override
  List<Object?> get props => [];
}

class PaymentsLoadedState extends PaymentState {
  const PaymentsLoadedState({
    required this.payments,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  final List<PaymentEntity> payments;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  PaymentsLoadedState copyWith({
    List<PaymentEntity>? payments,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) =>
      PaymentsLoadedState(
        payments: payments ?? this.payments,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [payments, hasMore, currentPage, isLoadingMore];
}

class PaymentErrorState extends PaymentState {
  const PaymentErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
