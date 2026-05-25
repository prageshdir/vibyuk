import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/campaign_list/campaign_list_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/campaign_banner.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key, this.destinationId});

  final String? destinationId;

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  static const _statusTabs = [
    (null, 'All'),
    (CampaignStatus.active, 'Active'),
    (CampaignStatus.draft, 'Draft'),
    (CampaignStatus.completed, 'Completed'),
    (CampaignStatus.paused, 'Paused'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    context.read<CampaignListBloc>().add(
          CampaignListLoaded(destinationId: widget.destinationId),
        );
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CampaignListBloc>().add(const CampaignListNextPage());
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final status = _statusTabs[_tabController.index].$1;
    context.read<CampaignListBloc>().add(CampaignListStatusFiltered(status));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourism Campaigns',
            style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _statusTabs
              .map((t) => Tab(text: t.$2))
              .toList(),
        ),
      ),
      body: BlocBuilder<CampaignListBloc, CampaignListState>(
        builder: (context, state) {
          if (state.status == CampaignListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CampaignListStatus.error &&
              state.campaigns.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load campaigns',
              onRetry: () => context
                  .read<CampaignListBloc>()
                  .add(const CampaignListRefreshed()),
            );
          }
          if (state.campaigns.isEmpty) {
            return const Center(child: Text('No campaigns found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<CampaignListBloc>()
                  .add(const CampaignListRefreshed());
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  state.campaigns.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == state.campaigns.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final campaign = state.campaigns[index];
                return CampaignBanner(
                  campaign: campaign,
                  onTap: () => context.push(
                    RouteNames.tourismCampaignDetailPath(campaign.id),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.tourismCampaigns),
        icon: const Icon(Icons.add),
        label: const Text('New Campaign'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
