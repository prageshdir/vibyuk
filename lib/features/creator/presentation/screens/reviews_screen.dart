import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/presentation/blocs/reviews/reviews_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/creator_empty_state.dart';
import 'package:vibyuk/features/creator/presentation/widgets/review_card.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ReviewsBloc>().add(const LoadReviewsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<ReviewsBloc>().add(const LoadMoreReviewsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<ReviewsBloc, ReviewsState>(
        builder: (context, state) => switch (state) {
          ReviewsLoadingState() => const Center(child: AppLoader()),
          ReviewsLoadedState(:final reviews, :final isLoadingMore) =>
            reviews.isEmpty
                ? const CreatorEmptyState.noReviews()
                : RefreshIndicator(
                    onRefresh: () async => context
                        .read<ReviewsBloc>()
                        .add(const LoadReviewsEvent()),
                    child: Column(
                      children: [
                        if (reviews.isNotEmpty)
                          _RatingSummary(reviews: reviews),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: reviews.length + (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == reviews.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: AppLoader(size: 24)),
                                );
                              }
                              return ReviewCardFactory.fromEntity(reviews[i]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ReviewsErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<ReviewsBloc>()
                        .add(const LoadReviewsEvent()),
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
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.reviews});
  final List reviews;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0, (s, r) => s + (r.rating as double)) /
            reviews.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final fill = i < avg.floor();
                  final half = !fill && i < avg;
                  return Icon(
                    fill
                        ? Icons.star_rounded
                        : half
                            ? Icons.star_half_rounded
                            : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${reviews.length} Review${reviews.length == 1 ? '' : 's'}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Based on completed bookings',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
