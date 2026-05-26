part of 'booking_requests_bloc.dart';

sealed class BookingRequestsState extends Equatable {
  const BookingRequestsState();
}

class BookingRequestsInitialState extends BookingRequestsState {
  const BookingRequestsInitialState();
  @override
  List<Object?> get props => [];
}

class BookingRequestsLoadingState extends BookingRequestsState {
  const BookingRequestsLoadingState();
  @override
  List<Object?> get props => [];
}

class BookingRequestsLoadedState extends BookingRequestsState {
  const BookingRequestsLoadedState({
    required this.requests,
    required this.hasMore,
    required this.currentPage,
    this.statusFilter,
    this.isLoadingMore = false,
    this.isLoadingDetail = false,
    this.isResponding = false,
    this.selectedRequest,
    this.detailError,
    this.respondError,
    this.respondSuccess = false,
  });

  final List<BookingRequestEntity> requests;
  final bool hasMore;
  final int currentPage;
  final BookingRequestStatus? statusFilter;
  final bool isLoadingMore;
  final bool isLoadingDetail;
  final bool isResponding;
  final BookingRequestEntity? selectedRequest;
  final Failure? detailError;
  final Failure? respondError;
  final bool respondSuccess;

  BookingRequestsLoadedState copyWith({
    List<BookingRequestEntity>? requests,
    bool? hasMore,
    int? currentPage,
    BookingRequestStatus? statusFilter,
    bool? isLoadingMore,
    bool? isLoadingDetail,
    bool? isResponding,
    BookingRequestEntity? selectedRequest,
    Failure? detailError,
    Failure? respondError,
    bool? respondSuccess,
  }) =>
      BookingRequestsLoadedState(
        requests: requests ?? this.requests,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        statusFilter: statusFilter ?? this.statusFilter,
        isLoadingMore: isLoadingMore ?? false,
        isLoadingDetail: isLoadingDetail ?? false,
        isResponding: isResponding ?? false,
        selectedRequest: selectedRequest ?? this.selectedRequest,
        detailError: detailError,
        respondError: respondError,
        respondSuccess: respondSuccess ?? false,
      );

  @override
  List<Object?> get props => [
        requests,
        hasMore,
        currentPage,
        statusFilter,
        isLoadingMore,
        isLoadingDetail,
        isResponding,
        selectedRequest,
        detailError,
        respondError,
        respondSuccess,
      ];
}

class BookingRequestsErrorState extends BookingRequestsState {
  const BookingRequestsErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
