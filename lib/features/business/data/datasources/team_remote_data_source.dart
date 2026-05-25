import 'package:dio/dio.dart';
import 'package:vibyuk/features/business/data/dtos/invite_team_member_dto.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';

abstract interface class TeamRemoteDataSource {
  Future<List<dynamic>> getTeamMembers();
  Future<Map<String, dynamic>> inviteTeamMember(InviteTeamMemberDto dto);
  Future<void> removeTeamMember(String memberId);
  Future<Map<String, dynamic>> updateTeamMemberRole(
      String memberId, TeamRole role);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  TeamRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  static const _basePath = '/team';

  Map<String, dynamic> _data(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  @override
  Future<List<dynamic>> getTeamMembers() async {
    final response = await _dio.get(_basePath);
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is List) {
      return body['data'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> inviteTeamMember(
      InviteTeamMemberDto dto) async {
    final response =
        await _dio.post('$_basePath/invite', data: dto.toJson());
    return _data(response);
  }

  @override
  Future<void> removeTeamMember(String memberId) async {
    await _dio.delete('$_basePath/$memberId');
  }

  @override
  Future<Map<String, dynamic>> updateTeamMemberRole(
      String memberId, TeamRole role) async {
    final response = await _dio.patch(
      '$_basePath/$memberId/role',
      data: {'role': role.name},
    );
    return _data(response);
  }
}
