import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/data/datasources/analytics_remote_data_source.dart';
import 'package:vibyuk/features/business/data/models/analytics_model.dart';
import 'package:vibyuk/features/business/domain/entities/analytics_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl extends BaseRepository implements AnalyticsRepository {
  AnalyticsRepositoryImpl({required AnalyticsRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final AnalyticsRemoteDataSource _remote;

  @override
  Future<Either<Failure, AnalyticsDashboardEntity>> getAnalyticsDashboard({
    required String period,
  }) =>
      safeCall(() async {
        final data = await _remote.getAnalyticsDashboard(period);
        return AnalyticsDashboardModel.fromJson(data).toEntity();
      });
}
