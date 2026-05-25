part of 'admin_disputes_bloc.dart';

enum AdminDisputesStatus { initial, loading, loaded, loadingMore, error }

final class AdminDisputesState extends Equatable {
  final AdminDisputesStatus status;
  final List<AdminDispute> disputes;
  final AdminDispute? selectedDispute;
  final DisputeStatus? statusFilter;
  final DisputeType? typeFilter;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;
  final bool isActioning;
  final String? errorMessage;
  final String? actionSuccess;

  const AdminDisputesState({
    this.status = AdminDisputesStatus.initial,
    this.disputes = const [],
    this.selectedDispute,
    this.statusFilter,
    this.typeFilter,
    this.searchQuery = '',
    this.currentPage = 0,
    this.hasMore = true,
    this.isActioning = false,
    this.errorMessage,
    this.actionSuccess,
  });

  AdminDisputesState copyWith({
    AdminDisputesStatus? status,
    List<AdminDispute>? disputes,
    AdminDispute? selectedDispute,
    DisputeStatus? Function()? statusFilter,
    DisputeType? Function()? typeFilter,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    bool? isActioning,
    String? errorMessage,
    String? actionSuccess,
  }) {
    return AdminDisputesState(
      status: status ?? this.status,
      disputes: disputes ?? this.disputes,
      selectedDispute: selectedDispute ?? this.selectedDispute,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      typeFilter: typeFilter != null ? typeFilter() : this.typeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isActioning: isActioning ?? this.isActioning,
      errorMessage: errorMessage,
      actionSuccess: actionSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status, disputes, selectedDispute, statusFilter, typeFilter,
        searchQuery, currentPage, hasMore, isActioning,
        errorMessage, actionSuccess,
      ];
}
