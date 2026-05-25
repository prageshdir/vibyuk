import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/network/paginated_response.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class GetVendorBookingsUseCase
    extends UseCase<PaginatedResponse<WeddingBookingEntity>, GetVendorBookingsParams> {
  const GetVendorBookingsUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<WeddingBookingEntity>>> call(
    GetVendorBookingsParams params,
  ) =>
      _repository.getVendorBookings(
        params.weddingId,
        page: params.page,
        perPage: params.perPage,
      );
}

class GetVendorBookingsParams extends Equatable {
  const GetVendorBookingsParams({
    required this.weddingId,
    this.page = 1,
    this.perPage = 20,
  });

  final String weddingId;
  final int page;
  final int perPage;

  @override
  List<Object?> get props => [weddingId, page, perPage];
}
