import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class SendPhoneOtpUseCase implements UseCase<String, SendPhoneOtpParams> {
  SendPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, String>> call(SendPhoneOtpParams params) {
    return _repository.sendPhoneOtp(phone: params.phone);
  }
}

class SendPhoneOtpParams extends Equatable {
  final String phone;

  const SendPhoneOtpParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}
