import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailOtpUseCase implements UseCase<Unit, VerifyEmailOtpParams> {
  VerifyEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(VerifyEmailOtpParams params) {
    return _repository.verifyEmailOtp(
      email: params.email,
      otp: params.otp,
    );
  }
}

class VerifyEmailOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyEmailOtpParams({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}
