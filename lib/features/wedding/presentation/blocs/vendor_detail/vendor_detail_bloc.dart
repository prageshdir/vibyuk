import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';
import 'package:vibyuk/features/wedding/domain/usecases/create_vendor_booking_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_vendor_detail_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class VendorDetailEvent extends Equatable {
  const VendorDetailEvent();
}

final class VendorDetailLoadRequested extends VendorDetailEvent {
  final String vendorId;
  const VendorDetailLoadRequested({required this.vendorId});

  @override
  List<Object?> get props => [vendorId];
}

final class VendorDetailBookingRequested extends VendorDetailEvent {
  final String weddingId;
  final double agreedPrice;
  final DateTime eventDate;
  final double? depositAmount;
  final String? notes;

  const VendorDetailBookingRequested({
    required this.weddingId,
    required this.agreedPrice,
    required this.eventDate,
    this.depositAmount,
    this.notes,
  });

  @override
  List<Object?> get props => [weddingId, agreedPrice, eventDate, depositAmount, notes];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class VendorDetailState extends Equatable {
  const VendorDetailState();
}

final class VendorDetailInitial extends VendorDetailState {
  const VendorDetailInitial();

  @override
  List<Object?> get props => [];
}

final class VendorDetailLoading extends VendorDetailState {
  const VendorDetailLoading();

  @override
  List<Object?> get props => [];
}

final class VendorDetailLoaded extends VendorDetailState {
  final WeddingVendorEntity vendor;
  final bool isBooking;

  const VendorDetailLoaded({required this.vendor, this.isBooking = false});

  VendorDetailLoaded copyWith({WeddingVendorEntity? vendor, bool? isBooking}) =>
      VendorDetailLoaded(
        vendor: vendor ?? this.vendor,
        isBooking: isBooking ?? this.isBooking,
      );

  @override
  List<Object?> get props => [vendor, isBooking];
}

final class VendorDetailError extends VendorDetailState {
  final Failure failure;
  const VendorDetailError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

final class VendorDetailBookingSuccess extends VendorDetailState {
  final WeddingBookingEntity booking;
  const VendorDetailBookingSuccess({required this.booking});

  @override
  List<Object?> get props => [booking];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class VendorDetailBloc
    extends BaseBloc<VendorDetailEvent, VendorDetailState> {
  VendorDetailBloc({
    required GetVendorDetailUseCase getVendorDetail,
    required CreateVendorBookingUseCase createBooking,
  })  : _getVendorDetail = getVendorDetail,
        _createBooking = createBooking,
        super(const VendorDetailInitial()) {
    on<VendorDetailLoadRequested>(_onLoadRequested);
    on<VendorDetailBookingRequested>(_onBookingRequested);
  }

  final GetVendorDetailUseCase _getVendorDetail;
  final CreateVendorBookingUseCase _createBooking;

  String? _currentVendorId;

  Future<void> _onLoadRequested(
    VendorDetailLoadRequested event,
    Emitter<VendorDetailState> emit,
  ) async {
    _currentVendorId = event.vendorId;
    emit(const VendorDetailLoading());
    final result = await _getVendorDetail(VendorIdParams(event.vendorId));
    result.fold(
      (f) => emit(VendorDetailError(failure: f)),
      (vendor) => emit(VendorDetailLoaded(vendor: vendor)),
    );
  }

  Future<void> _onBookingRequested(
    VendorDetailBookingRequested event,
    Emitter<VendorDetailState> emit,
  ) async {
    final current = state;
    if (current is! VendorDetailLoaded) return;

    emit(current.copyWith(isBooking: true));
    final result = await _createBooking(CreateVendorBookingParams(
      weddingId: event.weddingId,
      vendorId: _currentVendorId!,
      agreedPrice: event.agreedPrice,
      eventDate: event.eventDate,
      depositAmount: event.depositAmount,
      notes: event.notes,
    ));
    result.fold(
      (f) => emit(VendorDetailError(failure: f)),
      (booking) => emit(VendorDetailBookingSuccess(booking: booking)),
    );
  }
}
