import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class UploadProfileImageUseCase extends UseCase<String, UploadImageParams> {
  final CreatorRepository _repository;
  const UploadProfileImageUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(UploadImageParams params) =>
      _repository.uploadProfileImage(filePath: params.filePath);
}

class UploadCoverImageUseCase extends UseCase<String, UploadImageParams> {
  final CreatorRepository _repository;
  const UploadCoverImageUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(UploadImageParams params) =>
      _repository.uploadCoverImage(filePath: params.filePath);
}

class UploadImageParams extends Equatable {
  final String filePath;
  const UploadImageParams({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}
