import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_contract_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class GetContractUseCase
    extends UseCase<BookingContractEntity, BookingIdParams> {
  const GetContractUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingContractEntity>> call(BookingIdParams params) =>
      _repository.getContract(params.bookingId);
}

class SignContractUseCase
    extends UseCase<BookingContractEntity, BookingIdParams> {
  const SignContractUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingContractEntity>> call(BookingIdParams params) =>
      _repository.signContract(params.bookingId);
}

class BookingIdParams extends Equatable {
  const BookingIdParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}
