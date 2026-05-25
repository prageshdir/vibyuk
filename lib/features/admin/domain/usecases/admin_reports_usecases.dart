import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';
import 'package:vibyuk/features/admin/domain/repositories/admin_repository.dart';

class GetReportsUseCase
    implements UseCase<PaginatedResponse<AdminReport>, GetReportsParams> {
  final AdminRepository _repository;

  const GetReportsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<AdminReport>>> call(
    GetReportsParams params,
  ) {
    return _repository.getReports(
      page: params.page,
      statusFilter: params.statusFilter,
      categoryFilter: params.categoryFilter,
      searchQuery: params.searchQuery,
    );
  }
}

class GetReportDetailUseCase implements UseCase<AdminReport, ReportIdParams> {
  final AdminRepository _repository;

  const GetReportDetailUseCase(this._repository);

  @override
  Future<Either<Failure, AdminReport>> call(ReportIdParams params) {
    return _repository.getReportDetail(reportId: params.reportId);
  }
}

class HandleReportUseCase implements UseCase<AdminReport, HandleReportParams> {
  final AdminRepository _repository;

  const HandleReportUseCase(this._repository);

  @override
  Future<Either<Failure, AdminReport>> call(HandleReportParams params) {
    return _repository.handleReport(
      reportId: params.reportId,
      action: params.action,
      note: params.note,
    );
  }
}

// ── Params ────────────────────────────────────────────────────────────────────

class GetReportsParams extends Equatable {
  final int page;
  final ReportStatus? statusFilter;
  final ReportCategory? categoryFilter;
  final String? searchQuery;

  const GetReportsParams({
    this.page = 1,
    this.statusFilter,
    this.categoryFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page, statusFilter, categoryFilter, searchQuery];
}

class ReportIdParams extends Equatable {
  final String reportId;

  const ReportIdParams({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

class HandleReportParams extends Equatable {
  final String reportId;
  final ReportActionType action;
  final String? note;

  const HandleReportParams({
    required this.reportId,
    required this.action,
    this.note,
  });

  @override
  List<Object?> get props => [reportId, action, note];
}
