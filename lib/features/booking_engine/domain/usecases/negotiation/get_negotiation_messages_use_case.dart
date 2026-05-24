import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_negotiation_message_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class GetNegotiationMessagesUseCase
    extends UseCase<List<BookingNegotiationMessageEntity>, NegotiationParams> {
  const GetNegotiationMessagesUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, List<BookingNegotiationMessageEntity>>> call(
          NegotiationParams params) =>
      _repository.getNegotiationMessages(params.bookingId);
}

class SendNegotiationMessageUseCase
    extends UseCase<BookingNegotiationMessageEntity, SendNegotiationParams> {
  const SendNegotiationMessageUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingNegotiationMessageEntity>> call(
          SendNegotiationParams params) =>
      _repository.sendNegotiationMessage(
        bookingId: params.bookingId,
        type: params.type,
        message: params.message,
        offeredPrice: params.offeredPrice,
        currency: params.currency,
      );
}

class NegotiationParams extends Equatable {
  const NegotiationParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

class SendNegotiationParams extends Equatable {
  const SendNegotiationParams({
    required this.bookingId,
    required this.type,
    this.message,
    this.offeredPrice,
    this.currency,
  });
  final String bookingId;
  final NegotiationMessageType type;
  final String? message;
  final double? offeredPrice;
  final String? currency;

  @override
  List<Object?> get props =>
      [bookingId, type, message, offeredPrice, currency];
}
