import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';
import 'package:vibyuk/features/tourism/domain/usecases/create_collaboration_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_collaborations_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/update_collaboration_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class CreatorCollaborationEvent extends Equatable {
  const CreatorCollaborationEvent();
  @override
  List<Object?> get props => [];
}

final class CollaborationListLoaded extends CreatorCollaborationEvent {
  const CollaborationListLoaded({this.destinationId, this.campaignId});
  final String? destinationId;
  final String? campaignId;
  @override
  List<Object?> get props => [destinationId, campaignId];
}

final class CollaborationNextPage extends CreatorCollaborationEvent {
  const CollaborationNextPage();
}

final class CollaborationCreated extends CreatorCollaborationEvent {
  const CollaborationCreated(this.params);
  final CreateCollaborationParams params;
  @override
  List<Object?> get props => [params];
}

final class CollaborationUpdated extends CreatorCollaborationEvent {
  const CollaborationUpdated(this.params);
  final UpdateCollaborationParams params;
  @override
  List<Object?> get props => [params];
}

final class CollaborationRefreshed extends CreatorCollaborationEvent {
  const CollaborationRefreshed();
}

// ── State ─────────────────────────────────────────────────────────────────────

final class CreatorCollaborationState extends Equatable {
  const CreatorCollaborationState({
    this.status = CollaborationStatus2.initial,
    this.collaborations = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.destinationId,
    this.campaignId,
    this.actionStatus = CollaborationActionStatus.idle,
    this.errorMessage,
  });

  final CollaborationStatus2 status;
  final List<CreatorCollaborationEntity> collaborations;
  final int currentPage;
  final bool hasMore;
  final String? destinationId;
  final String? campaignId;
  final CollaborationActionStatus actionStatus;
  final String? errorMessage;

  bool get isLoadingMore => status == CollaborationStatus2.loadingMore;

  CreatorCollaborationState copyWith({
    CollaborationStatus2? status,
    List<CreatorCollaborationEntity>? collaborations,
    int? currentPage,
    bool? hasMore,
    String? destinationId,
    String? campaignId,
    CollaborationActionStatus? actionStatus,
    String? errorMessage,
  }) =>
      CreatorCollaborationState(
        status: status ?? this.status,
        collaborations: collaborations ?? this.collaborations,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        destinationId: destinationId ?? this.destinationId,
        campaignId: campaignId ?? this.campaignId,
        actionStatus: actionStatus ?? this.actionStatus,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        collaborations,
        currentPage,
        hasMore,
        destinationId,
        campaignId,
        actionStatus,
        errorMessage,
      ];
}

enum CollaborationStatus2 { initial, loading, loadingMore, loaded, error }

enum CollaborationActionStatus { idle, submitting, success, error }

// ── BLoC ─────────────────────────────────────────────────────────────────────

class CreatorCollaborationBloc
    extends BaseBloc<CreatorCollaborationEvent, CreatorCollaborationState> {
  CreatorCollaborationBloc({
    required GetCollaborationsUseCase getCollaborations,
    required CreateCollaborationUseCase createCollaboration,
    required UpdateCollaborationUseCase updateCollaboration,
  })  : _getCollaborations = getCollaborations,
        _createCollaboration = createCollaboration,
        _updateCollaboration = updateCollaboration,
        super(const CreatorCollaborationState()) {
    on<CollaborationListLoaded>(_onListLoaded);
    on<CollaborationNextPage>(_onNextPage);
    on<CollaborationCreated>(_onCreated);
    on<CollaborationUpdated>(_onUpdated);
    on<CollaborationRefreshed>(_onRefreshed);
  }

  final GetCollaborationsUseCase _getCollaborations;
  final CreateCollaborationUseCase _createCollaboration;
  final UpdateCollaborationUseCase _updateCollaboration;

  Future<void> _onListLoaded(
    CollaborationListLoaded event,
    Emitter<CreatorCollaborationState> emit,
  ) async {
    emit(state.copyWith(
      status: CollaborationStatus2.loading,
      destinationId: event.destinationId,
      campaignId: event.campaignId,
    ));

    final result = await _getCollaborations(GetCollaborationsParams(
      page: 1,
      destinationId: event.destinationId,
      campaignId: event.campaignId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CollaborationStatus2.error,
        errorMessage: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        status: CollaborationStatus2.loaded,
        collaborations: paginated.items,
        currentPage: 1,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onNextPage(
    CollaborationNextPage event,
    Emitter<CreatorCollaborationState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(status: CollaborationStatus2.loadingMore));
    final nextPage = state.currentPage + 1;

    final result = await _getCollaborations(GetCollaborationsParams(
      page: nextPage,
      destinationId: state.destinationId,
      campaignId: state.campaignId,
    ));

    result.fold(
      (failure) =>
          emit(state.copyWith(status: CollaborationStatus2.loaded)),
      (paginated) => emit(state.copyWith(
        status: CollaborationStatus2.loaded,
        collaborations: [...state.collaborations, ...paginated.items],
        currentPage: nextPage,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onCreated(
    CollaborationCreated event,
    Emitter<CreatorCollaborationState> emit,
  ) async {
    emit(state.copyWith(actionStatus: CollaborationActionStatus.submitting));
    final result = await _createCollaboration(event.params);
    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: CollaborationActionStatus.error,
        errorMessage: failure.message,
      )),
      (collab) => emit(state.copyWith(
        actionStatus: CollaborationActionStatus.success,
        collaborations: [collab, ...state.collaborations],
      )),
    );
  }

  Future<void> _onUpdated(
    CollaborationUpdated event,
    Emitter<CreatorCollaborationState> emit,
  ) async {
    emit(state.copyWith(actionStatus: CollaborationActionStatus.submitting));
    final result = await _updateCollaboration(event.params);
    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: CollaborationActionStatus.error,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        actionStatus: CollaborationActionStatus.success,
        collaborations: state.collaborations
            .map((c) => c.id == updated.id ? updated : c)
            .toList(),
      )),
    );
  }

  Future<void> _onRefreshed(
    CollaborationRefreshed event,
    Emitter<CreatorCollaborationState> emit,
  ) {
    add(CollaborationListLoaded(
      destinationId: state.destinationId,
      campaignId: state.campaignId,
    ));
    return Future.value();
  }
}
