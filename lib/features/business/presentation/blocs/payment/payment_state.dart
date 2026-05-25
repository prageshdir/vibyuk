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
    this.statusFilter,
  });

  final List<PaymentEntity> payments;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final PaymentStatus? statusFilter;

  PaymentsLoadedState copyWith({
    List<PaymentEntity>? payments,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    PaymentStatus? statusFilter,
    bool clearFilter = false,
  }) =>
      PaymentsLoadedState(
        payments: payments ?? this.payments,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
      );

  @override
  List<Object?> get props => [
        payments,
        hasMore,
        currentPage,
        isLoadingMore,
        statusFilter,
      ];
}

class PaymentErrorState extends PaymentState {
  const PaymentErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class PaymentInitiatingState extends PaymentState {
  const PaymentInitiatingState();
  @override
  List<Object?> get props => [];
}

class PaymentOrderCreatedState extends PaymentState {
  const PaymentOrderCreatedState({required this.order});
  final PaymentOrderEntity order;
  @override
  List<Object?> get props => [order];
}

class PaymentVerifiedState extends PaymentState {
  const PaymentVerifiedState({required this.payment});
  final PaymentEntity payment;
  @override
  List<Object?> get props => [payment];
}
