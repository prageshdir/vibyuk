import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_destination_detail_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_featured_destinations_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class DestinationDetailEvent extends Equatable {
  const DestinationDetailEvent();
  @override
  List<Object?> get props => [];
}

final class DestinationDetailLoaded extends DestinationDetailEvent {
  const DestinationDetailLoaded(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

// ── State ─────────────────────────────────────────────────────────────────────

final class DestinationDetailState extends Equatable {
  const DestinationDetailState({
    this.status = DestinationDetailStatus.initial,
    this.destination,
    this.similarDestinations = const [],
    this.errorMessage,
  });

  final DestinationDetailStatus status;
  final TourismDestinationEntity? destination;
  final List<TourismDestinationEntity> similarDestinations;
  final String? errorMessage;

  DestinationDetailState copyWith({
    DestinationDetailStatus? status,
    TourismDestinationEntity? destination,
    List<TourismDestinationEntity>? similarDestinations,
    String? errorMessage,
  }) =>
      DestinationDetailState(
        status: status ?? this.status,
        destination: destination ?? this.destination,
        similarDestinations:
            similarDestinations ?? this.similarDestinations,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, destination, similarDestinations, errorMessage];
}

enum DestinationDetailStatus { initial, loading, loaded, error }

// ── BLoC ─────────────────────────────────────────────────────────────────────

class DestinationDetailBloc
    extends BaseBloc<DestinationDetailEvent, DestinationDetailState> {
  DestinationDetailBloc({
    required GetDestinationDetailUseCase getDestinationDetail,
    required GetFeaturedDestinationsUseCase getFeaturedDestinations,
  })  : _getDestinationDetail = getDestinationDetail,
        _getFeaturedDestinations = getFeaturedDestinations,
        super(const DestinationDetailState()) {
    on<DestinationDetailLoaded>(_onLoaded);
  }

  final GetDestinationDetailUseCase _getDestinationDetail;
  final GetFeaturedDestinationsUseCase _getFeaturedDestinations;

  Future<void> _onLoaded(
    DestinationDetailLoaded event,
    Emitter<DestinationDetailState> emit,
  ) async {
    emit(state.copyWith(status: DestinationDetailStatus.loading));

    final detailResult =
        await _getDestinationDetail(DestinationIdParams(event.id));

    await detailResult.fold(
      (failure) async => emit(state.copyWith(
        status: DestinationDetailStatus.error,
        errorMessage: failure.message,
      )),
      (destination) async {
        final similarResult = await _getFeaturedDestinations();
        final similar = similarResult.fold(
          (_) => <TourismDestinationEntity>[],
          (list) => list.where((d) => d.id != destination.id).take(5).toList(),
        );
        emit(state.copyWith(
          status: DestinationDetailStatus.loaded,
          destination: destination,
          similarDestinations: similar,
        ));
      },
    );
  }
}
