import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/chat/domain/entities/media_upload_entity.dart';
import 'package:vibyuk/features/chat/domain/repositories/chat_repository.dart';

class UploadMediaUseCase implements UseCase<MediaUploadEntity, File> {
  const UploadMediaUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<Either<Failure, MediaUploadEntity>> call(File file) =>
      _repository.uploadMedia(file);
}
