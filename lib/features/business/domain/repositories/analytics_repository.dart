import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/analytics_entity.dart';

abstract interface class AnalyticsRepository {
  Future<Either<Failure, AnalyticsDashboardEntity>> getAnalyticsDashboard({
    required String period,
  });
}
