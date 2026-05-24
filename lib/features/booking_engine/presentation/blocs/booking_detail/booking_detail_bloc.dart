import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/cancel_booking_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/confirm_booking_use_case.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/bookings/get_booking_detail_use_case.dart';

part 'booking_detail_event.dart';
part 'booking_detail_state.dart';

class BookingDetailBloc
    extends BaseBloc<BookingDetailEvent, BookingDetailState> {
  BookingDetailBloc({
    required GetBookingDetailUseCase getDetail,
    required ConfirmBookingUseCase confirm,
    required CancelBookingUseCase cancel,
  })  : _getDetail = getDetail,
        _confirm = confirm,
        _cancel = cancel,
        super(const BookingDetailInitialState()) {
    on<LoadBookingDetailEvent>(_onLoad);
    on<ConfirmBookingDetailEvent>(_onConfirm);
    on<CancelBookingDetailEvent>(_onCancel);
  }

  final GetBookingDetailUseCase _getDetail;
  final ConfirmBookingUseCase _confirm;
  final CancelBookingUseCase _cancel;

  Future<void> _onLoad(
      LoadBookingDetailEvent event, Emitter<BookingDetailState> emit) async {
    emit(const BookingDetailLoadingState());
    final result =
        await _getDetail(GetBookingDetailParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(BookingDetailErrorState(failure: f)),
      (b) => emit(BookingDetailLoadedState(booking: b)),
    );
  }

  Future<void> _onConfirm(
      ConfirmBookingDetailEvent event, Emitter<BookingDetailState> emit) async {
    if (state is! BookingDetailLoadedState) return;
    final current = state as BookingDetailLoadedState;
    emit(current.copyWith(isActioning: true));
    final result =
        await _confirm(ConfirmBookingParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(current.copyWith(actionError: f)),
      (b) => emit(BookingDetailLoadedState(
          booking: b, actionSuccess: true)),
    );
  }

  Future<void> _onCancel(
      CancelBookingDetailEvent event, Emitter<BookingDetailState> emit) async {
    if (state is! BookingDetailLoadedState) return;
    final current = state as BookingDetailLoadedState;
    emit(current.copyWith(isActioning: true));
    final result = await _cancel(
        CancelBookingParams(bookingId: event.bookingId, reason: event.reason));
    result.fold(
      (f) => emit(current.copyWith(actionError: f)),
      (b) => emit(BookingDetailLoadedState(
          booking: b, actionSuccess: true)),
    );
  }
}
