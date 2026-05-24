import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/escrow_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class GetEscrowDetailsUseCase implements UseCase<EscrowEntity, String> {
  const GetEscrowDetailsUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, EscrowEntity>> call(String bookingId) =>
      _repository.getEscrowDetails(bookingId);
}
