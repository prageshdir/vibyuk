import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/campaign_application_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/campaign_applications/campaign_applications_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/campaign_application_card.dart';
import 'package:vibyuk/features/creator/presentation/widgets/creator_empty_state.dart';

class CampaignApplicationsScreen extends StatefulWidget {
  const CampaignApplicationsScreen({super.key});

  @override
  State<CampaignApplicationsScreen> createState() =>
      _CampaignApplicationsScreenState();
}

class _CampaignApplicationsScreenState
    extends State<CampaignApplicationsScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final TabController _tabController;

  static const _tabs = [
    (label: 'All', status: null),
    (label: 'Pending', status: ApplicationStatus.pending),
    (label: 'Accepted', status: ApplicationStatus.accepted),
    (label: 'Rejected', status: ApplicationStatus.rejected),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<CampaignApplicationsBloc>().add(const LoadApplicationsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    context.read<CampaignApplicationsBloc>().add(
          FilterApplicationsEvent(
              statusFilter: _tabs[_tabController.index].status),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context
          .read<CampaignApplicationsBloc>()
          .add(const LoadMoreApplicationsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: BlocBuilder<CampaignApplicationsBloc, CampaignApplicationsState>(
        builder: (context, state) => switch (state) {
          CampaignApplicationsLoadingState() =>
            const Center(child: AppLoader()),
          CampaignApplicationsLoadedState(
            :final applications,
            :final isLoadingMore
          ) =>
            applications.isEmpty
                ? const CreatorEmptyState.noApplications()
                : RefreshIndicator(
                    onRefresh: () async => context
                        .read<CampaignApplicationsBloc>()
                        .add(const LoadApplicationsEvent()),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          applications.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == applications.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: AppLoader(size: 24)),
                          );
                        }
                        final app = applications[i];
                        return CampaignApplicationCard(
                          application: app,
                          onWithdraw: app.isPending
                              ? () => _confirmWithdraw(context, app)
                              : null,
                        );
                      },
                    ),
                  ),
          CampaignApplicationsErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.campaign_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<CampaignApplicationsBloc>()
                        .add(const LoadApplicationsEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _confirmWithdraw(
      BuildContext context, CampaignApplicationEntity app) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Withdraw Application'),
        content:
            Text('Withdraw your application for "${app.campaignTitle}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CampaignApplicationsBloc>().add(
                    WithdrawApplicationEvent(applicationId: app.id),
                  );
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
