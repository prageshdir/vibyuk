import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class GetEventsUseCase
    implements UseCase<PaginatedResponse<EventEntity>, GetEventsParams> {
  const GetEventsUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<EventEntity>>> call(
    GetEventsParams params,
  ) => _repository.getEvents(
    page: params.page,
    perPage: params.perPage,
    category: params.category,
    query: params.query,
    myEventsOnly: params.myEventsOnly,
  );
}

class GetEventsParams extends Equatable {
  final int page;
  final int perPage;
  final EventCategory? category;
  final String? query;
  final bool myEventsOnly;

  const GetEventsParams({
    this.page = 1,
    this.perPage = 20,
    this.category,
    this.query,
    this.myEventsOnly = false,
  });

  @override
  List<Object?> get props => [page, perPage, category, query, myEventsOnly];
}
