import 'package:flutter/material.dart';
import 'package:vibyuk/features/creator/domain/entities/review_entity.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewHeader(review: review),
            if (review.dimensions != null) ...[
              const SizedBox(height: 12),
              _DimensionRatings(dimensions: review.dimensions!),
            ],
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(review.comment!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
            ],
            if (review.isVerifiedBooking) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      size: 13, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('Verified booking',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.green)),
                ],
              ),
            ],
            if (review.creatorResponse != null &&
                review.creatorResponse!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _CreatorResponse(
                response: review.creatorResponse!,
                respondedAt: review.creatorRespondedAt,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.review});
  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          backgroundImage: review.reviewerAvatarUrl != null
              ? NetworkImage(review.reviewerAvatarUrl!)
              : null,
          child: review.reviewerAvatarUrl == null
              ? Text(review.reviewerName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.reviewerName,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text(_formatDate(review.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        _StarRating(rating: review.effectiveRating),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

class _DimensionRatings extends StatelessWidget {
  const _DimensionRatings({required this.dimensions});
  final ReviewDimensions dimensions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _DimensionRow(
              label: 'Professionalism', score: dimensions.professionalism),
          const SizedBox(height: 4),
          _DimensionRow(label: 'Quality', score: dimensions.quality),
          const SizedBox(height: 4),
          _DimensionRow(label: 'Timeliness', score: dimensions.timeliness),
        ],
      ),
    );
  }
}

class _DimensionRow extends StatelessWidget {
  const _DimensionRow({required this.label, required this.score});
  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 5.0,
              backgroundColor:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(score.toStringAsFixed(1),
            style: theme.textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CreatorResponse extends StatelessWidget {
  const _CreatorResponse({required this.response, this.respondedAt});
  final String response;
  final DateTime? respondedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.reply_rounded,
                  size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Creator response',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (respondedAt != null) ...[
                const Spacer(),
                Text(
                  '${respondedAt!.day}/${respondedAt!.month}/${respondedAt!.year}',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(response,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded, color: Colors.amber, size: 16);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded,
              color: Colors.amber, size: 16);
        }
        return const Icon(Icons.star_border_rounded,
            color: Colors.amber, size: 16);
      }),
    );
  }
}
