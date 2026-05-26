import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/bookings/get_booking_request_detail_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/bookings/get_booking_requests_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/bookings/respond_to_booking_request_use_case.dart';

part 'booking_requests_event.dart';
part 'booking_requests_state.dart';

class BookingRequestsBloc
    extends BaseBloc<BookingRequestsEvent, BookingRequestsState> {
  BookingRequestsBloc({
    required GetBookingRequestsUseCase getRequests,
    required GetBookingRequestDetailUseCase getDetail,
    required RespondToBookingRequestUseCase respond,
  })  : _getRequests = getRequests,
        _getDetail = getDetail,
        _respond = respond,
        super(const BookingRequestsInitialState()) {
    on<LoadBookingRequestsEvent>(_onLoad);
    on<LoadMoreBookingRequestsEvent>(_onLoadMore);
    on<FilterBookingRequestsEvent>(_onFilter);
    on<LoadBookingRequestDetailEvent>(_onLoadDetail);
    on<RespondToBookingRequestEvent>(_onRespond);
  }

  final GetBookingRequestsUseCase _getRequests;
  final GetBookingRequestDetailUseCase _getDetail;
  final RespondToBookingRequestUseCase _respond;

  int _currentPage = 1;
  static const int _pageSize = 20;
  BookingRequestStatus? _statusFilter;

  Future<void> _onLoad(LoadBookingRequestsEvent event,
      Emitter<BookingRequestsState> emit) async {
    emit(const BookingRequestsLoadingState());
    _currentPage = 1;
    _statusFilter = event.statusFilter;
    final result = await _getRequests(GetBookingRequestsParams(
      page: _currentPage,
      pageSize: _pageSize,
      statusFilter: _statusFilter,
    ));
    result.fold(
      (f) => emit(BookingRequestsErrorState(failure: f)),
      (r) => emit(BookingRequestsLoadedState(
        requests: r.items,
        hasMore: r.hasNextPage,
        currentPage: _currentPage,
        statusFilter: _statusFilter,
      )),
    );
  }

  Future<void> _onLoadMore(LoadMoreBookingRequestsEvent event,
      Emitter<BookingRequestsState> emit) async {
    if (state is! BookingRequestsLoadedState) return;
    final current = state as BookingRequestsLoadedState;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getRequests(GetBookingRequestsParams(
      page: _currentPage + 1,
      pageSize: _pageSize,
      statusFilter: _statusFilter,
    ));
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (r) {
        _currentPage++;
        emit(current.copyWith(
          requests: [...current.requests, ...r.items],
          hasMore: r.hasNextPage,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onFilter(FilterBookingRequestsEvent event,
      Emitter<BookingRequestsState> emit) async {
    add(LoadBookingRequestsEvent(statusFilter: event.statusFilter));
  }

  Future<void> _onLoadDetail(LoadBookingRequestDetailEvent event,
      Emitter<BookingRequestsState> emit) async {
    if (state is! BookingRequestsLoadedState) return;
    final current = state as BookingRequestsLoadedState;
    emit(current.copyWith(isLoadingDetail: true));
    final result =
        await _getDetail(GetBookingRequestDetailParams(requestId: event.requestId));
    result.fold(
      (f) => emit(current.copyWith(isLoadingDetail: false, detailError: f)),
      (r) => emit(current.copyWith(isLoadingDetail: false, selectedRequest: r)),
    );
  }

  Future<void> _onRespond(RespondToBookingRequestEvent event,
      Emitter<BookingRequestsState> emit) async {
    if (state is! BookingRequestsLoadedState) return;
    final current = state as BookingRequestsLoadedState;
    emit(current.copyWith(isResponding: true));
    final result = await _respond(RespondToBookingRequestParams(
      requestId: event.requestId,
      accept: event.accept,
      counterOfferPrice: event.counterOfferPrice,
      counterOfferMessage: event.counterOfferMessage,
    ));
    result.fold(
      (f) => emit(current.copyWith(isResponding: false, respondError: f)),
      (updated) {
        final requests = current.requests
            .map((r) => r.id == updated.id ? updated : r)
            .toList();
        emit(current.copyWith(
          requests: requests,
          isResponding: false,
          respondSuccess: true,
          selectedRequest: updated,
        ));
      },
    );
  }
}
