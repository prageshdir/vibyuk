import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_platform_analytics.dart';
import 'package:vibyuk/features/admin/domain/repositories/admin_repository.dart';

class GetPlatformAnalyticsUseCase
    implements UseCase<AdminPlatformAnalytics, GetAnalyticsParams> {
  final AdminRepository _repository;

  const GetPlatformAnalyticsUseCase(this._repository);

  @override
  Future<Either<Failure, AdminPlatformAnalytics>> call(
    GetAnalyticsParams params,
  ) {
    return _repository.getPlatformAnalytics(period: params.period);
  }
}

// ── Params ────────────────────────────────────────────────────────────────────

class GetAnalyticsParams extends Equatable {
  final AdminAnalyticsPeriod period;

  const GetAnalyticsParams({this.period = AdminAnalyticsPeriod.last30Days});

  @override
  List<Object?> get props => [period];
}
