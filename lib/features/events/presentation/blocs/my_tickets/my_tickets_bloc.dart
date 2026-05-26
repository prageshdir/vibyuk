import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/core/pagination/pagination_bloc.dart';
import 'package:vibyuk/core/pagination/pagination_event.dart';
import 'package:vibyuk/core/pagination/pagination_state.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/usecases/get_my_tickets_usecase.dart';

final class TicketStatusFilterChanged extends PaginationEvent {
  final TicketStatus? status;
  const TicketStatusFilterChanged({this.status});

  @override
  List<Object?> get props => [status];
}

class MyTicketsBloc extends PaginationBloc<TicketEntity> {
  MyTicketsBloc({required GetMyTicketsUseCase getMyTickets})
      : _getMyTickets = getMyTickets {
    on<TicketStatusFilterChanged>(_onStatusFilterChanged);
  }

  final GetMyTicketsUseCase _getMyTickets;
  TicketStatus? _statusFilter;

  @override
  PageFetcher<TicketEntity> get fetcher => (int page) => _getMyTickets(
        GetMyTicketsParams(
          page: page,
          perPage: 20,
          statusFilter: _statusFilter,
        ),
      );

  Future<void> _onStatusFilterChanged(
    TicketStatusFilterChanged event,
    Emitter<PaginationState<TicketEntity>> emit,
  ) async {
    _statusFilter = event.status;
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
