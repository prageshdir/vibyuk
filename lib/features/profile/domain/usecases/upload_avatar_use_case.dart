import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class UploadAvatarUseCase implements UseCase<String, UploadAvatarParams> {
  UploadAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, String>> call(UploadAvatarParams params) {
    return _repository.uploadAvatar(params.filePath);
  }
}

class UploadAvatarParams extends Equatable {
  final String filePath;

  const UploadAvatarParams({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}
