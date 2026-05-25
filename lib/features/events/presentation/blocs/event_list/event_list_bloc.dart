import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/core/pagination/pagination_bloc.dart';
import 'package:vibyuk/core/pagination/pagination_event.dart';
import 'package:vibyuk/core/pagination/pagination_state.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/usecases/get_events_usecase.dart';

// Extra events for filtering — extend PaginationEvent so they flow through
// the same Bloc<PaginationEvent, PaginationState<EventEntity>> type.

final class EventCategoryFilterChanged extends PaginationEvent {
  final EventCategory? category;
  const EventCategoryFilterChanged({this.category});

  @override
  List<Object?> get props => [category];
}

final class EventSearchChanged extends PaginationEvent {
  final String query;
  const EventSearchChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

final class EventMyEventsToggled extends PaginationEvent {
  final bool myEventsOnly;
  const EventMyEventsToggled({required this.myEventsOnly});

  @override
  List<Object?> get props => [myEventsOnly];
}

class EventListBloc extends PaginationBloc<EventEntity> {
  EventListBloc({required GetEventsUseCase getEvents}) : _getEvents = getEvents {
    on<EventCategoryFilterChanged>(_onCategoryChanged);
    on<EventSearchChanged>(_onSearchChanged);
    on<EventMyEventsToggled>(_onMyEventsToggled);
  }

  final GetEventsUseCase _getEvents;

  EventCategory? _category;
  String _query = '';
  bool _myEventsOnly = false;

  @override
  PageFetcher<EventEntity> get fetcher => (int page) => _getEvents(
        GetEventsParams(
          page: page,
          perPage: 20,
          category: _category,
          query: _query.isEmpty ? null : _query,
          myEventsOnly: _myEventsOnly,
        ),
      );

  Future<void> _onCategoryChanged(
    EventCategoryFilterChanged event,
    Emitter<PaginationState<EventEntity>> emit,
  ) async {
    _category = event.category;
    emit(const PaginationLoading());
    final result = await fetcher(1);
    result.fold(
      (failure) => emit(PaginationError(failure: failure)),
      (response) => response.isEmpty
          ? emit(const PaginationEmpty())
          : emit(PaginationLoaded(
              response: response,
              hasReachedEnd: response.isLastPage,
            )),
    );
  }

  Future<void> _onSearchChanged(
    EventSearchChanged event,
    Emitter<PaginationState<EventEntity>> emit,
  ) async {
    _query = event.query;
    emit(const PaginationLoading());
    final result = await fetcher(1);
    result.fold(
      (failure) => emit(PaginationError(failure: failure)),
      (response) => response.isEmpty
          ? emit(const PaginationEmpty())
          : emit(PaginationLoaded(
              response: response,
              hasReachedEnd: response.isLastPage,
            )),
    );
  }

  Future<void> _onMyEventsToggled(
    EventMyEventsToggled event,
    Emitter<PaginationState<EventEntity>> emit,
  ) async {
    _myEventsOnly = event.myEventsOnly;
    emit(const PaginationLoading());
    final result = await fetcher(1);
    result.fold(
      (failure) => emit(PaginationError(failure: failure)),
      (response) => response.isEmpty
          ? emit(const PaginationEmpty())
          : emit(PaginationLoaded(
              response: response,
              hasReachedEnd: response.isLastPage,
            )),
    );
  }
}
