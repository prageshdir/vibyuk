import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetBookingRequestsUseCase
    extends UseCase<PaginatedResult<BookingRequestEntity>, GetBookingRequestsParams> {
  final CreatorRepository _repository;
  const GetBookingRequestsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<BookingRequestEntity>>> call(
          GetBookingRequestsParams params) =>
      _repository.getBookingRequests(
        page: params.page,
        pageSize: params.pageSize,
        statusFilter: params.statusFilter,
      );
}

class GetBookingRequestsParams extends Equatable {
  final int page;
  final int pageSize;
  final BookingRequestStatus? statusFilter;

  const GetBookingRequestsParams({
    required this.page,
    this.pageSize = 20,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [page, pageSize, statusFilter];
}
