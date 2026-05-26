import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';
import 'package:vibyuk/features/tourism/domain/usecases/apply_for_fam_trip_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_fam_trip_detail_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_fam_trips_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class FamTripEvent extends Equatable {
  const FamTripEvent();
  @override
  List<Object?> get props => [];
}

final class FamTripListLoaded extends FamTripEvent {
  const FamTripListLoaded({this.destinationId, this.status});
  final String? destinationId;
  final FamTripStatus? status;
  @override
  List<Object?> get props => [destinationId, status];
}

final class FamTripNextPage extends FamTripEvent {
  const FamTripNextPage();
}

final class FamTripDetailLoaded extends FamTripEvent {
  const FamTripDetailLoaded(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

final class FamTripApplicationSubmitted extends FamTripEvent {
  const FamTripApplicationSubmitted(this.params);
  final ApplyFamTripParams params;
  @override
  List<Object?> get props => [params];
}

final class FamTripRefreshed extends FamTripEvent {
  const FamTripRefreshed();
}

// ── State ─────────────────────────────────────────────────────────────────────

final class FamTripState extends Equatable {
  const FamTripState({
    this.status = FamTripStateStatus.initial,
    this.trips = const [],
    this.selectedTrip,
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedStatus,
    this.destinationId,
    this.applicationStatus = FamTripApplicationStatus.idle,
    this.errorMessage,
  });

  final FamTripStateStatus status;
  final List<FamTripEntity> trips;
  final FamTripEntity? selectedTrip;
  final int currentPage;
  final bool hasMore;
  final FamTripStatus? selectedStatus;
  final String? destinationId;
  final FamTripApplicationStatus applicationStatus;
  final String? errorMessage;

  bool get isLoadingMore => status == FamTripStateStatus.loadingMore;
  bool get isApplying =>
      applicationStatus == FamTripApplicationStatus.submitting;

  FamTripState copyWith({
    FamTripStateStatus? status,
    List<FamTripEntity>? trips,
    FamTripEntity? selectedTrip,
    int? currentPage,
    bool? hasMore,
    FamTripStatus? selectedStatus,
    String? destinationId,
    FamTripApplicationStatus? applicationStatus,
    String? errorMessage,
  }) =>
      FamTripState(
        status: status ?? this.status,
        trips: trips ?? this.trips,
        selectedTrip: selectedTrip ?? this.selectedTrip,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        selectedStatus: selectedStatus ?? this.selectedStatus,
        destinationId: destinationId ?? this.destinationId,
        applicationStatus: applicationStatus ?? this.applicationStatus,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        trips,
        selectedTrip,
        currentPage,
        hasMore,
        selectedStatus,
        destinationId,
        applicationStatus,
        errorMessage,
      ];
}

enum FamTripStateStatus { initial, loading, loadingMore, loaded, error }

enum FamTripApplicationStatus { idle, submitting, success, error }

// ── BLoC ─────────────────────────────────────────────────────────────────────

class FamTripBloc extends BaseBloc<FamTripEvent, FamTripState> {
  FamTripBloc({
    required GetFamTripsUseCase getFamTrips,
    required GetFamTripDetailUseCase getFamTripDetail,
    required ApplyForFamTripUseCase applyForFamTrip,
  })  : _getFamTrips = getFamTrips,
        _getFamTripDetail = getFamTripDetail,
        _applyForFamTrip = applyForFamTrip,
        super(const FamTripState()) {
    on<FamTripListLoaded>(_onListLoaded);
    on<FamTripNextPage>(_onNextPage);
    on<FamTripDetailLoaded>(_onDetailLoaded);
    on<FamTripApplicationSubmitted>(_onApplicationSubmitted);
    on<FamTripRefreshed>(_onRefreshed);
  }

  final GetFamTripsUseCase _getFamTrips;
  final GetFamTripDetailUseCase _getFamTripDetail;
  final ApplyForFamTripUseCase _applyForFamTrip;

  Future<void> _onListLoaded(
    FamTripListLoaded event,
    Emitter<FamTripState> emit,
  ) async {
    emit(state.copyWith(
      status: FamTripStateStatus.loading,
      destinationId: event.destinationId,
      selectedStatus: event.status,
    ));

    final result = await _getFamTrips(GetFamTripsParams(
      page: 1,
      destinationId: event.destinationId,
      status: event.status,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: FamTripStateStatus.error,
        errorMessage: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        status: FamTripStateStatus.loaded,
        trips: paginated.items,
        currentPage: 1,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onNextPage(
    FamTripNextPage event,
    Emitter<FamTripState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(status: FamTripStateStatus.loadingMore));
    final nextPage = state.currentPage + 1;

    final result = await _getFamTrips(GetFamTripsParams(
      page: nextPage,
      destinationId: state.destinationId,
      status: state.selectedStatus,
    ));

    result.fold(
      (failure) => emit(state.copyWith(status: FamTripStateStatus.loaded)),
      (paginated) => emit(state.copyWith(
        status: FamTripStateStatus.loaded,
        trips: [...state.trips, ...paginated.items],
        currentPage: nextPage,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onDetailLoaded(
    FamTripDetailLoaded event,
    Emitter<FamTripState> emit,
  ) async {
    emit(state.copyWith(status: FamTripStateStatus.loading));
    final result = await _getFamTripDetail(FamTripIdParams(event.id));
    result.fold(
      (failure) => emit(state.copyWith(
        status: FamTripStateStatus.error,
        errorMessage: failure.message,
      )),
      (trip) => emit(state.copyWith(
        status: FamTripStateStatus.loaded,
        selectedTrip: trip,
      )),
    );
  }

  Future<void> _onApplicationSubmitted(
    FamTripApplicationSubmitted event,
    Emitter<FamTripState> emit,
  ) async {
    emit(state.copyWith(
        applicationStatus: FamTripApplicationStatus.submitting));
    final result = await _applyForFamTrip(event.params);
    result.fold(
      (failure) => emit(state.copyWith(
        applicationStatus: FamTripApplicationStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
          applicationStatus: FamTripApplicationStatus.success)),
    );
  }

  Future<void> _onRefreshed(
    FamTripRefreshed event,
    Emitter<FamTripState> emit,
  ) {
    add(FamTripListLoaded(
      destinationId: state.destinationId,
      status: state.selectedStatus,
    ));
    return Future.value();
  }
}
