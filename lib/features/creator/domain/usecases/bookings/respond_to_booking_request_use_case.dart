import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class RespondToBookingRequestUseCase
    extends UseCase<BookingRequestEntity, RespondToBookingRequestParams> {
  final CreatorRepository _repository;
  const RespondToBookingRequestUseCase(this._repository);

  @override
  Future<Either<Failure, BookingRequestEntity>> call(
          RespondToBookingRequestParams params) =>
      _repository.respondToBookingRequest(
        requestId: params.requestId,
        accept: params.accept,
        counterOfferPrice: params.counterOfferPrice,
        counterOfferMessage: params.counterOfferMessage,
      );
}

class RespondToBookingRequestParams extends Equatable {
  final String requestId;
  final bool accept;
  final double? counterOfferPrice;
  final String? counterOfferMessage;

  const RespondToBookingRequestParams({
    required this.requestId,
    required this.accept,
    this.counterOfferPrice,
    this.counterOfferMessage,
  });

  @override
  List<Object?> get props => [requestId, accept, counterOfferPrice, counterOfferMessage];
}
