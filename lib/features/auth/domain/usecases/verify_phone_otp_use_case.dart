import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/auth_session_entity.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class VerifyPhoneOtpUseCase implements UseCase<AuthSessionEntity, VerifyPhoneOtpParams> {
  VerifyPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSessionEntity>> call(VerifyPhoneOtpParams params) {
    return _repository.verifyPhoneOtp(
      phone: params.phone,
      otp: params.otp,
    );
  }
}

class VerifyPhoneOtpParams extends Equatable {
  final String phone;
  final String otp;

  const VerifyPhoneOtpParams({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}
