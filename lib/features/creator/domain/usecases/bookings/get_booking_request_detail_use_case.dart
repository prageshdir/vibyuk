import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetBookingRequestDetailUseCase
    extends UseCase<BookingRequestEntity, GetBookingRequestDetailParams> {
  final CreatorRepository _repository;
  const GetBookingRequestDetailUseCase(this._repository);

  @override
  Future<Either<Failure, BookingRequestEntity>> call(
          GetBookingRequestDetailParams params) =>
      _repository.getBookingRequestDetail(requestId: params.requestId);
}

class GetBookingRequestDetailParams extends Equatable {
  final String requestId;
  const GetBookingRequestDetailParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}
