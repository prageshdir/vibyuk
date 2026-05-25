import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_reports_usecases.dart';

part 'admin_reports_event.dart';
part 'admin_reports_state.dart';

class AdminReportsBloc
    extends BaseBloc<AdminReportsEvent, AdminReportsState> {
  final GetReportsUseCase _getReports;
  final GetReportDetailUseCase _getReportDetail;
  final HandleReportUseCase _handleReport;

  AdminReportsBloc({
    required GetReportsUseCase getReports,
    required GetReportDetailUseCase getReportDetail,
    required HandleReportUseCase handleReport,
  })  : _getReports = getReports,
        _getReportDetail = getReportDetail,
        _handleReport = handleReport,
        super(const AdminReportsState()) {
    on<AdminReportsFetch>(_onFetch);
    on<AdminReportsLoadMore>(_onLoadMore);
    on<AdminReportsSearchChanged>(_onSearchChanged);
    on<AdminReportsStatusFilterChanged>(_onStatusFilterChanged);
    on<AdminReportsCategoryFilterChanged>(_onCategoryFilterChanged);
    on<AdminReportsSelectReport>(_onSelectReport);
    on<AdminReportsHandleReport>(_onHandleReport);
  }

  Future<void> _onFetch(
    AdminReportsFetch event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(state.copyWith(
      status: AdminReportsLoadStatus.loading,
      reports: event.refresh ? [] : state.reports,
      currentPage: event.refresh ? 0 : state.currentPage,
    ));

    final result = await _getReports(GetReportsParams(
      page: 1,
      statusFilter: state.statusFilter,
      categoryFilter: state.categoryFilter,
      searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminReportsLoadStatus.error,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: AdminReportsLoadStatus.loaded,
        reports: page.items,
        currentPage: 1,
        hasMore: page.hasNextPage,
      )),
    );
  }

  Future<void> _onLoadMore(
    AdminReportsLoadMore event,
    Emitter<AdminReportsState> emit,
  ) async {
    if (!state.hasMore || state.status == AdminReportsLoadStatus.loadingMore) {
      return;
    }
    emit(state.copyWith(status: AdminReportsLoadStatus.loadingMore));

    final result = await _getReports(GetReportsParams(
      page: state.currentPage + 1,
      statusFilter: state.statusFilter,
      categoryFilter: state.categoryFilter,
      searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminReportsLoadStatus.loaded,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: AdminReportsLoadStatus.loaded,
        reports: [...state.reports, ...page.items],
        currentPage: state.currentPage + 1,
        hasMore: page.hasNextPage,
      )),
    );
  }

  Future<void> _onSearchChanged(
    AdminReportsSearchChanged event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(AdminReportsFetch(refresh: true));
  }

  Future<void> _onStatusFilterChanged(
    AdminReportsStatusFilterChanged event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(state.copyWith(statusFilter: () => event.status));
    add(AdminReportsFetch(refresh: true));
  }

  Future<void> _onCategoryFilterChanged(
    AdminReportsCategoryFilterChanged event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(state.copyWith(categoryFilter: () => event.category));
    add(AdminReportsFetch(refresh: true));
  }

  Future<void> _onSelectReport(
    AdminReportsSelectReport event,
    Emitter<AdminReportsState> emit,
  ) async {
    final result =
        await _getReportDetail(ReportIdParams(reportId: event.reportId));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (report) => emit(state.copyWith(selectedReport: report)),
    );
  }

  Future<void> _onHandleReport(
    AdminReportsHandleReport event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(state.copyWith(isHandling: true));
    final result = await _handleReport(HandleReportParams(
      reportId: event.reportId,
      action: event.action,
      note: event.note,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        isHandling: false,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        isHandling: false,
        selectedReport: updated,
        reports: state.reports
            .map((r) => r.id == updated.id ? updated : r)
            .toList(),
        handleSuccess: 'Report handled successfully',
      )),
    );
  }
}
