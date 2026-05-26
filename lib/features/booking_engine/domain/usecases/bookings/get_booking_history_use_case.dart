import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';

class GetBookingHistoryUseCase
    extends UseCase<PaginatedResult<BookingEntity>, GetBookingHistoryParams> {
  const GetBookingHistoryUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<BookingEntity>>> call(
          GetBookingHistoryParams params) =>
      _repository.getBookingHistory(page: params.page, pageSize: params.pageSize);
}

class GetBookingHistoryParams extends Equatable {
  const GetBookingHistoryParams({this.page = 1, this.pageSize = 20});
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [page, pageSize];
}
