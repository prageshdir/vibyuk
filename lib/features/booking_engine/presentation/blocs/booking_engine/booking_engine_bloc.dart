import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/get_bookings_use_case.dart';

part 'booking_engine_event.dart';
part 'booking_engine_state.dart';

class BookingEngineBloc
    extends BaseBloc<BookingEngineEvent, BookingEngineState> {
  BookingEngineBloc({required GetBookingsUseCase getBookings})
      : _getBookings = getBookings,
        super(const BookingEngineInitialState()) {
    on<LoadBookingsEvent>(_onLoad);
    on<LoadMoreBookingsEvent>(_onLoadMore);
    on<FilterBookingsEvent>(_onFilter);
    on<RefreshBookingsEvent>(_onRefresh);
  }

  final GetBookingsUseCase _getBookings;
  int _currentPage = 1;
  static const int _pageSize = 20;
  BookingStatus? _statusFilter;

  Future<void> _onLoad(
      LoadBookingsEvent event, Emitter<BookingEngineState> emit) async {
    emit(const BookingEngineLoadingState());
    _currentPage = 1;
    _statusFilter = event.statusFilter;
    final result = await _getBookings(GetBookingsParams(
      status: _statusFilter,
      page: _currentPage,
      pageSize: _pageSize,
    ));
    result.fold(
      (f) => emit(BookingEngineErrorState(failure: f)),
      (r) => emit(BookingEngineLoadedState(
        bookings: r.items,
        hasMore: r.hasNextPage,
        currentPage: _currentPage,
        statusFilter: _statusFilter,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMoreBookingsEvent event, Emitter<BookingEngineState> emit) async {
    if (state is! BookingEngineLoadedState) return;
    final current = state as BookingEngineLoadedState;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getBookings(GetBookingsParams(
      status: _statusFilter,
      page: _currentPage + 1,
      pageSize: _pageSize,
    ));
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (r) {
        _currentPage++;
        emit(current.copyWith(
          bookings: [...current.bookings, ...r.items],
          hasMore: r.hasNextPage,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onFilter(
      FilterBookingsEvent event, Emitter<BookingEngineState> emit) async {
    add(LoadBookingsEvent(statusFilter: event.statusFilter));
  }

  Future<void> _onRefresh(
      RefreshBookingsEvent event, Emitter<BookingEngineState> emit) async {
    add(LoadBookingsEvent(statusFilter: _statusFilter));
  }
}
