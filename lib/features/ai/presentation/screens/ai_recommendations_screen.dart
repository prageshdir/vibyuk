import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_recommendations/ai_recommendations_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_recommendations/ai_recommendations_event.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_recommendations/ai_recommendations_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/cards/ai_recommendation_card.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_empty_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_gradient_header.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_loading_shimmer.dart';

class AiRecommendationsScreen extends StatefulWidget {
  const AiRecommendationsScreen({super.key});

  @override
  State<AiRecommendationsScreen> createState() =>
      _AiRecommendationsScreenState();
}

class _AiRecommendationsScreenState extends State<AiRecommendationsScreen> {
  static const _eventTypes = [
    'All Events',
    'Corporate',
    'Wedding',
    'Festival',
    'Birthday',
    'Conference',
  ];

  String _selectedEventType = 'All Events';
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadRecommendations() {
    context.read<AiRecommendationsBloc>().add(
          LoadRecommendations(
            eventType: _selectedEventType,
            budget: 5000,
            location: 'London, UK',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle:
                NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  AiGradientHeader(
                    title: 'Creator Match',
                    subtitle: 'AI-ranked creators for your event',
                    trailing: IconButton(
                      icon: const Icon(Icons.tune_rounded, color: Colors.white),
                      onPressed: _showFilterSheet,
                    ),
                  ),
                  // Event type filter chips
                  Container(
                    height: 48,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _eventTypes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final type = _eventTypes[i];
                        final isSelected = type == _selectedEventType;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedEventType = type);
                            _loadRecommendations();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: AppColors.brandGradient,
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: BlocBuilder<AiRecommendationsBloc, AiRecommendationsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const AiLoadingShimmer(cardCount: 4, cardHeight: 220);
            }

            if (state.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(state.failure?.message ?? 'Something went wrong'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRecommendations,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!state.hasData) {
              return AiEmptyState(
                title: 'No creators found',
                message:
                    'Try adjusting your filters or event type to find matching creators',
                icon: Icons.person_search_rounded,
                actionLabel: 'Adjust Filters',
                onAction: _showFilterSheet,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AiRecommendationsBloc>()
                    .add(const RefreshRecommendations());
              },
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.filteredRecommendations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final rec = state.filteredRecommendations[i];
                  return AiRecommendationCard(
                    recommendation: rec,
                    onBookmark: () => context
                        .read<AiRecommendationsBloc>()
                        .add(ToggleBookmarkRecommendation(
                          recommendationId: rec.id,
                        )),
                    onBook: () {
                      // Navigate to booking flow
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        onApply: (category, maxBudget, minRating) {
          context.read<AiRecommendationsBloc>().add(
                FilterRecommendations(
                  category: category,
                  maxBudget: maxBudget,
                  minRating: minRating,
                ),
              );
        },
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final Function(String?, double?, double?) onApply;

  const _FilterSheet({required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  double _maxBudget = 5000;
  double _minRating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Creators',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Max Budget',
              style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _maxBudget,
            min: 500,
            max: 20000,
            divisions: 39,
            activeColor: AppColors.primary,
            label: '£${_maxBudget.toStringAsFixed(0)}',
            onChanged: (v) => setState(() => _maxBudget = v),
          ),
          const SizedBox(height: 8),
          const Text('Min Rating',
              style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            activeColor: AppColors.warning,
            label: _minRating.toStringAsFixed(1),
            onChanged: (v) => setState(() => _minRating = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(null, _maxBudget, _minRating);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
