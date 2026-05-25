import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class ResendEmailOtpUseCase implements UseCase<Unit, ResendEmailOtpParams> {
  ResendEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ResendEmailOtpParams params) {
    return _repository.resendEmailOtp(email: params.email);
  }
}

class ResendEmailOtpParams extends Equatable {
  final String email;

  const ResendEmailOtpParams({required this.email});

  @override
  List<Object?> get props => [email];
}
