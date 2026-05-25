import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class GetMyTicketsUseCase
    implements UseCase<PaginatedResponse<TicketEntity>, GetMyTicketsParams> {
  const GetMyTicketsUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<TicketEntity>>> call(
    GetMyTicketsParams params,
  ) => _repository.getMyTickets(
    page: params.page,
    perPage: params.perPage,
    statusFilter: params.statusFilter,
  );
}

class GetMyTicketsParams extends Equatable {
  final int page;
  final int perPage;
  final TicketStatus? statusFilter;

  const GetMyTicketsParams({
    this.page = 1,
    this.perPage = 20,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [page, perPage, statusFilter];
}
