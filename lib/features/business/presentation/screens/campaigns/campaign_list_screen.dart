import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/campaign/campaign_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';
import 'package:vibyuk/features/business/presentation/widgets/campaign_card.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  static const _tabs = [
    (label: 'All', status: null),
    (label: 'Active', status: CampaignStatus.active),
    (label: 'Draft', status: CampaignStatus.draft),
    (label: 'Paused', status: CampaignStatus.paused),
    (label: 'Done', status: CampaignStatus.completed),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<CampaignBloc>().add(const LoadCampaignsEvent());
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<CampaignBloc>().add(const LoadMoreCampaignsEvent());
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final status = _tabs[_tabController.index].status;
    context
        .read<CampaignBloc>()
        .add(FilterCampaignsByStatusEvent(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs
              .map((t) => Tab(text: t.label))
              .toList(),
        ),
      ),
      body: BlocBuilder<CampaignBloc, CampaignState>(
        builder: (context, state) => switch (state) {
          CampaignLoadingState() =>
            const Center(child: AppLoader()),
          CampaignsLoadedState(:final campaigns, :final isLoadingMore) =>
            campaigns.isEmpty
                ? BusinessEmptyState.noCampaigns(
                    onCreate: () => context.push('/campaigns/create'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: campaigns.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == campaigns.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: AppLoader(size: 24)),
                        );
                      }
                      final campaign = campaigns[index];
                      return CampaignCard(
                        campaign: campaign,
                        onTap: () =>
                            context.push('/campaigns/${campaign.id}'),
                        onMenuTap: () =>
                            _showCampaignMenu(context, campaign),
                      );
                    },
                  ),
          CampaignErrorState(:final failure) =>
            BusinessEmptyState(
              title: 'Failed to load campaigns',
              description: failure.message,
              icon: Icons.error_outline_rounded,
              actionLabel: 'Retry',
              onAction: () => context
                  .read<CampaignBloc>()
                  .add(const LoadCampaignsEvent()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/campaigns/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Campaign'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showCampaignMenu(BuildContext context, CampaignEntity campaign) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (campaign.canPublish)
              ListTile(
                leading: const Icon(Icons.publish_rounded,
                    color: AppColors.success),
                title: const Text('Publish campaign'),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<CampaignBloc>()
                      .add(PublishCampaignEvent(campaignId: campaign.id));
                },
              ),
            if (campaign.canEdit)
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/campaigns/${campaign.id}/edit');
                },
              ),
            ListTile(
              leading:
                  const Icon(Icons.delete_rounded, color: AppColors.error),
              title: const Text('Delete',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<CampaignBloc>()
                    .add(DeleteCampaignEvent(campaignId: campaign.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
