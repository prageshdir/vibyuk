part of 'admin_reports_bloc.dart';

sealed class AdminReportsEvent {}

final class AdminReportsFetch extends AdminReportsEvent {
  final bool refresh;
  AdminReportsFetch({this.refresh = false});
}

final class AdminReportsLoadMore extends AdminReportsEvent {}

final class AdminReportsSearchChanged extends AdminReportsEvent {
  final String query;
  AdminReportsSearchChanged(this.query);
}

final class AdminReportsStatusFilterChanged extends AdminReportsEvent {
  final ReportStatus? status;
  AdminReportsStatusFilterChanged(this.status);
}

final class AdminReportsCategoryFilterChanged extends AdminReportsEvent {
  final ReportCategory? category;
  AdminReportsCategoryFilterChanged(this.category);
}

final class AdminReportsSelectReport extends AdminReportsEvent {
  final String reportId;
  AdminReportsSelectReport(this.reportId);
}

final class AdminReportsHandleReport extends AdminReportsEvent {
  final String reportId;
  final ReportActionType action;
  final String? note;

  AdminReportsHandleReport({
    required this.reportId,
    required this.action,
    this.note,
  });
}
