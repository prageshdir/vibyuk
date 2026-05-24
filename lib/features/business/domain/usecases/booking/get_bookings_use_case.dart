import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/repositories/booking_repository.dart';

class GetBookingsUseCase
    implements UseCase<PaginatedResult<BookingEntity>, GetBookingsParams> {
  GetBookingsUseCase(this._repository);
  final BookingRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<BookingEntity>>> call(GetBookingsParams params) {
    return _repository.getBookings(
      status: params.status,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetBookingsParams extends Equatable {
  const GetBookingsParams({this.status, this.page = 1, this.pageSize = 20});
  final BookingStatus? status;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [status, page, pageSize];
}
