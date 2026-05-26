part of 'campaign_applications_bloc.dart';

sealed class CampaignApplicationsState extends Equatable {
  const CampaignApplicationsState();
}

class CampaignApplicationsInitialState extends CampaignApplicationsState {
  const CampaignApplicationsInitialState();
  @override
  List<Object?> get props => [];
}

class CampaignApplicationsLoadingState extends CampaignApplicationsState {
  const CampaignApplicationsLoadingState();
  @override
  List<Object?> get props => [];
}

class CampaignApplicationsLoadedState extends CampaignApplicationsState {
  const CampaignApplicationsLoadedState({
    required this.applications,
    required this.hasMore,
    required this.currentPage,
    this.statusFilter,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
  });

  final List<CampaignApplicationEntity> applications;
  final bool hasMore;
  final int currentPage;
  final ApplicationStatus? statusFilter;
  final bool isLoadingMore;
  final bool isSubmitting;
  final Failure? submitError;
  final bool submitSuccess;

  CampaignApplicationsLoadedState copyWith({
    List<CampaignApplicationEntity>? applications,
    bool? hasMore,
    int? currentPage,
    ApplicationStatus? statusFilter,
    bool? isLoadingMore,
    bool? isSubmitting,
    Failure? submitError,
    bool? submitSuccess,
  }) =>
      CampaignApplicationsLoadedState(
        applications: applications ?? this.applications,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        statusFilter: statusFilter ?? this.statusFilter,
        isLoadingMore: isLoadingMore ?? false,
        isSubmitting: isSubmitting ?? false,
        submitError: submitError,
        submitSuccess: submitSuccess ?? false,
      );

  @override
  List<Object?> get props => [
        applications,
        hasMore,
        currentPage,
        statusFilter,
        isLoadingMore,
        isSubmitting,
        submitError,
        submitSuccess,
      ];
}

class CampaignApplicationsErrorState extends CampaignApplicationsState {
  const CampaignApplicationsErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
