import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/team_repository.dart';

class GetTeamUseCase implements NoParamUseCase<List<TeamMemberEntity>> {
  GetTeamUseCase(this._repository);
  final TeamRepository _repository;

  @override
  Future<Either<Failure, List<TeamMemberEntity>>> call() {
    return _repository.getTeamMembers();
  }
}
