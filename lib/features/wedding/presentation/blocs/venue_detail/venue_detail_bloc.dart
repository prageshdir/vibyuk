import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_venue_detail_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class VenueDetailEvent extends Equatable {
  const VenueDetailEvent();
}

final class VenueDetailLoadRequested extends VenueDetailEvent {
  final String venueId;
  const VenueDetailLoadRequested({required this.venueId});

  @override
  List<Object?> get props => [venueId];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class VenueDetailState extends Equatable {
  const VenueDetailState();
}

final class VenueDetailInitial extends VenueDetailState {
  const VenueDetailInitial();

  @override
  List<Object?> get props => [];
}

final class VenueDetailLoading extends VenueDetailState {
  const VenueDetailLoading();

  @override
  List<Object?> get props => [];
}

final class VenueDetailLoaded extends VenueDetailState {
  final WeddingVenueEntity venue;
  const VenueDetailLoaded({required this.venue});

  @override
  List<Object?> get props => [venue];
}

final class VenueDetailError extends VenueDetailState {
  final Failure failure;
  const VenueDetailError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class VenueDetailBloc extends BaseBloc<VenueDetailEvent, VenueDetailState> {
  VenueDetailBloc({required GetVenueDetailUseCase getVenueDetail})
      : _getVenueDetail = getVenueDetail,
        super(const VenueDetailInitial()) {
    on<VenueDetailLoadRequested>(_onLoadRequested);
  }

  final GetVenueDetailUseCase _getVenueDetail;

  Future<void> _onLoadRequested(
    VenueDetailLoadRequested event,
    Emitter<VenueDetailState> emit,
  ) async {
    emit(const VenueDetailLoading());
    final result = await _getVenueDetail(VenueIdParams(event.venueId));
    result.fold(
      (f) => emit(VenueDetailError(failure: f)),
      (venue) => emit(VenueDetailLoaded(venue: venue)),
    );
  }
}
