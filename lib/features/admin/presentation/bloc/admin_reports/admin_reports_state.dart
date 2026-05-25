part of 'admin_reports_bloc.dart';

enum AdminReportsLoadStatus { initial, loading, loaded, loadingMore, error }

final class AdminReportsState extends Equatable {
  final AdminReportsLoadStatus status;
  final List<AdminReport> reports;
  final AdminReport? selectedReport;
  final ReportStatus? statusFilter;
  final ReportCategory? categoryFilter;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;
  final bool isHandling;
  final String? errorMessage;
  final String? handleSuccess;

  const AdminReportsState({
    this.status = AdminReportsLoadStatus.initial,
    this.reports = const [],
    this.selectedReport,
    this.statusFilter,
    this.categoryFilter,
    this.searchQuery = '',
    this.currentPage = 0,
    this.hasMore = true,
    this.isHandling = false,
    this.errorMessage,
    this.handleSuccess,
  });

  AdminReportsState copyWith({
    AdminReportsLoadStatus? status,
    List<AdminReport>? reports,
    AdminReport? selectedReport,
    ReportStatus? Function()? statusFilter,
    ReportCategory? Function()? categoryFilter,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    bool? isHandling,
    String? errorMessage,
    String? handleSuccess,
  }) {
    return AdminReportsState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      categoryFilter:
          categoryFilter != null ? categoryFilter() : this.categoryFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isHandling: isHandling ?? this.isHandling,
      errorMessage: errorMessage,
      handleSuccess: handleSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status, reports, selectedReport, statusFilter, categoryFilter,
        searchQuery, currentPage, hasMore, isHandling,
        errorMessage, handleSuccess,
      ];
}
