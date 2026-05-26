import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';
import 'package:vibyuk/features/influencer/presentation/blocs/influencer_campaign/influencer_campaign_bloc.dart';
import 'package:vibyuk/features/influencer/presentation/widgets/influencer_campaign_card.dart';
import 'package:vibyuk/features/influencer/presentation/widgets/deliverable_review_sheet.dart';

class InfluencerCampaignsScreen extends StatefulWidget {
  const InfluencerCampaignsScreen({super.key});

  @override
  State<InfluencerCampaignsScreen> createState() =>
      _InfluencerCampaignsScreenState();
}

class _InfluencerCampaignsScreenState
    extends State<InfluencerCampaignsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  static const _tabs = [
    (null, 'All'),
    (InfluencerCampaignStatus.draft, 'Draft'),
    (InfluencerCampaignStatus.applications, 'Applications'),
    (InfluencerCampaignStatus.inProgress, 'In Progress'),
    (InfluencerCampaignStatus.completed, 'Completed'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    context
        .read<InfluencerCampaignBloc>()
        .add(const LoadInfluencerCampaignsEvent());
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
    final status = _tabs[_tabController.index].$1;
    context
        .read<InfluencerCampaignBloc>()
        .add(FilterInfluencerCampaignsEvent(status: status));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context
          .read<InfluencerCampaignBloc>()
          .add(const LoadMoreInfluencerCampaignsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Influencer Campaigns',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
        ),
      ),
      body: BlocBuilder<InfluencerCampaignBloc, InfluencerCampaignState>(
        builder: (context, state) => switch (state) {
          InfluencerCampaignLoading() =>
            const Center(child: AppLoader()),
          InfluencerCampaignLoaded(:final campaigns, :final isLoadingMore) =>
            campaigns.isEmpty
                ? _EmptyState(statusFilter: state.statusFilter)
                : RefreshIndicator(
                    onRefresh: () async => context
                        .read<InfluencerCampaignBloc>()
                        .add(LoadInfluencerCampaignsEvent(
                            status: state.statusFilter)),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: campaigns.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == campaigns.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: AppLoader(size: 24)),
                          );
                        }
                        return InfluencerCampaignCard(
                          campaign: campaigns[i],
                          onReviewDeliverable: (d) =>
                              _showDeliverableReview(context, d),
                        );
                      },
                    ),
                  ),
          InfluencerCampaignError(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<InfluencerCampaignBloc>()
                        .add(const LoadInfluencerCampaignsEvent()),
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

  void _showDeliverableReview(
      BuildContext context, ContentDeliverableEntity deliverable) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<InfluencerCampaignBloc>(),
        child: DeliverableReviewSheet(deliverable: deliverable),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.statusFilter});
  final InfluencerCampaignStatus? statusFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            statusFilter == null
                ? 'No influencer campaigns yet'
                : 'No ${statusFilter!.label.toLowerCase()} campaigns',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
