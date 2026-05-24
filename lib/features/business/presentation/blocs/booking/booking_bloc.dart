import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/booking/cancel_booking_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/booking/get_booking_detail_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/booking/get_bookings_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/booking/update_booking_status_use_case.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends BaseBloc<BookingEvent, BookingState> {
  BookingBloc({
    required GetBookingsUseCase getBookings,
    required GetBookingDetailUseCase getBookingDetail,
    required UpdateBookingStatusUseCase updateBookingStatus,
    required CancelBookingUseCase cancelBooking,
  })  : _getBookings = getBookings,
        _getBookingDetail = getBookingDetail,
        _updateBookingStatus = updateBookingStatus,
        _cancelBooking = cancelBooking,
        super(const BookingInitialState()) {
    on<LoadBookingsEvent>(_onLoad);
    on<LoadMoreBookingsEvent>(_onLoadMore);
    on<LoadBookingDetailEvent>(_onLoadDetail);
    on<UpdateBookingStatusEvent>(_onUpdateStatus);
    on<CancelBookingEvent>(_onCancel);
    on<FilterBookingsByStatusEvent>(_onFilter);
  }

  final GetBookingsUseCase _getBookings;
  final GetBookingDetailUseCase _getBookingDetail;
  final UpdateBookingStatusUseCase _updateBookingStatus;
  final CancelBookingUseCase _cancelBooking;

  Future<void> _onLoad(LoadBookingsEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoadingState());
    final result = await _getBookings(GetBookingsParams(status: event.status));
    result.fold(
      (f) => emit(BookingErrorState(failure: f)),
      (page) => emit(BookingsLoadedState(
        bookings: page.items,
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        filterStatus: event.status,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMoreBookingsEvent event, Emitter<BookingState> emit) async {
    if (state is! BookingsLoadedState) return;
    final loaded = state as BookingsLoadedState;
    if (!loaded.hasMore || loaded.isLoadingMore) return;

    emit(loaded.copyWith(isLoadingMore: true));
    final result = await _getBookings(GetBookingsParams(
      status: loaded.filterStatus,
      page: loaded.currentPage + 1,
    ));
    result.fold(
      (f) => emit(BookingErrorState(failure: f)),
      (page) => emit(loaded.copyWith(
        bookings: [...loaded.bookings, ...page.items],
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onLoadDetail(
      LoadBookingDetailEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoadingState());
    final result = await _getBookingDetail(
        GetBookingDetailParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(BookingErrorState(failure: f)),
      (b) => emit(BookingDetailLoadedState(booking: b)),
    );
  }

  Future<void> _onUpdateStatus(
      UpdateBookingStatusEvent event, Emitter<BookingState> emit) async {
    final result = await _updateBookingStatus(UpdateBookingStatusParams(
      bookingId: event.bookingId,
      status: event.status,
    ));
    result.fold(
      (f) => emit(BookingErrorState(failure: f)),
      (b) => emit(BookingStatusUpdatedState(booking: b)),
    );
  }

  Future<void> _onCancel(
      CancelBookingEvent event, Emitter<BookingState> emit) async {
    final result = await _cancelBooking(
        CancelBookingParams(bookingId: event.bookingId, reason: event.reason));
    result.fold(
      (f) => emit(BookingErrorState(failure: f)),
      (_) => emit(BookingCancelledState(bookingId: event.bookingId)),
    );
  }

  void _onFilter(FilterBookingsByStatusEvent event, Emitter<BookingState> emit) {
    add(LoadBookingsEvent(status: event.status));
  }
}
