import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class DeleteAccountUseCase implements UseCase<Unit, DeleteAccountParams> {
  DeleteAccountUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteAccountParams params) {
    return _repository.deleteAccount(password: params.password);
  }
}

class DeleteAccountParams extends Equatable {
  final String password;

  const DeleteAccountParams({required this.password});

  @override
  List<Object?> get props => [password];
}
