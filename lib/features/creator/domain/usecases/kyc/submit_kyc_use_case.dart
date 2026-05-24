import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/kyc_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class SubmitKycUseCase extends UseCase<KycEntity, SubmitKycParams> {
  final CreatorRepository _repository;
  const SubmitKycUseCase(this._repository);

  @override
  Future<Either<Failure, KycEntity>> call(SubmitKycParams params) =>
      _repository.submitKyc(
        documentType: params.documentType,
        documentFrontPath: params.documentFrontPath,
        documentBackPath: params.documentBackPath,
        selfiePath: params.selfiePath,
      );
}

class SubmitKycParams extends Equatable {
  final KycDocumentType documentType;
  final String documentFrontPath;
  final String? documentBackPath;
  final String selfiePath;

  const SubmitKycParams({
    required this.documentType,
    required this.documentFrontPath,
    this.documentBackPath,
    required this.selfiePath,
  });

  @override
  List<Object?> get props =>
      [documentType, documentFrontPath, documentBackPath, selfiePath];
}
