import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_insights/ai_insights_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_insights/ai_insights_event.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_insights/ai_insights_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/cards/ai_insight_card.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_gradient_header.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_loading_shimmer.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AiInsightsBloc>().add(const LoadInsights());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AiInsightsBloc>().add(const RefreshInsights());
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AiGradientHeader(
                title: 'Viby AI',
                subtitle: 'Your intelligent creator platform assistant',
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick actions grid
                  _QuickActionsGrid(),
                  const SizedBox(height: 24),

                  // AI Insights section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<AiInsightsBloc, AiInsightsState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const AiLoadingShimmer(
                          cardCount: 3,
                          cardHeight: 130,
                        );
                      }
                      if (state.insights.isEmpty) {
                        return _EmptyInsights();
                      }
                      return Column(
                        children: state.insights.take(4).map((insight) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AiInsightCard(
                              insight: insight,
                              isDismissing: state.dismissingIds
                                  .contains(insight.id),
                              onDismiss: () => context
                                  .read<AiInsightsBloc>()
                                  .add(DismissInsight(insightId: insight.id)),
                              onAction: insight.actionRoute != null
                                  ? () =>
                                      context.push(insight.actionRoute!)
                                  : null,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final _actions = const [
    _AiAction(
      icon: Icons.recommend_rounded,
      label: 'Creator\nMatch',
      sublabel: 'Find your perfect creator',
      gradient: [Color(0xFF7B2FFF), Color(0xFF9B5FFF)],
      route: RouteNames.aiRecommendations,
    ),
    _AiAction(
      icon: Icons.campaign_rounded,
      label: 'Campaign\nPlanner',
      sublabel: 'Build AI-powered campaigns',
      gradient: [Color(0xFFFF5C6B), Color(0xFFFF8C96)],
      route: RouteNames.aiCampaignPlanner,
    ),
    _AiAction(
      icon: Icons.sell_rounded,
      label: 'Price\nOptimizer',
      sublabel: 'AI market pricing',
      gradient: [Color(0xFF00D9C0), Color(0xFF00B8A9)],
      route: RouteNames.aiPricing,
    ),
    _AiAction(
      icon: Icons.analytics_rounded,
      label: 'Analytics\nDashboard',
      sublabel: 'Intelligent insights',
      gradient: [Color(0xFFFFAB00), Color(0xFFFF8F00)],
      route: RouteNames.aiAnalytics,
    ),
  ];

  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actions.length,
      itemBuilder: (context, index) {
        final action = _actions[index];
        return _QuickActionCard(action: action);
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _AiAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(action.route),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: action.gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: action.gradient.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: Icon(action.icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              action.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              action.sublabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyInsights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            'No insights yet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'AI will surface insights as you use the platform',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}

class _AiAction {
  final IconData icon;
  final String label;
  final String sublabel;
  final List<Color> gradient;
  final String route;

  const _AiAction({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradient,
    required this.route,
  });
}
