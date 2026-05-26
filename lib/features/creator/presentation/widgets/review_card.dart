import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final _ReviewData review;

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
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: review.avatarUrl != null
                      ? NetworkImage(review.avatarUrl!)
                      : null,
                  child: review.avatarUrl == null
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
                _StarRating(rating: review.rating),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(review.comment!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
            ],
            if (review.isVerified) ...[
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
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
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
          return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 16);
        }
        return const Icon(Icons.star_border_rounded, color: Colors.amber, size: 16);
      }),
    );
  }
}

// Thin data class so this widget has no direct entity import
class _ReviewData {
  const _ReviewData({
    required this.reviewerName,
    this.avatarUrl,
    required this.rating,
    this.comment,
    required this.isVerified,
    required this.createdAt,
  });
  final String reviewerName;
  final String? avatarUrl;
  final double rating;
  final String? comment;
  final bool isVerified;
  final DateTime createdAt;
}

// Factory constructor so callers can pass an entity
extension ReviewCardFactory on ReviewCard {
  static ReviewCard fromEntity(dynamic review) => ReviewCard(
        review: _ReviewData(
          reviewerName: review.reviewerName as String,
          avatarUrl: review.reviewerAvatarUrl as String?,
          rating: review.rating as double,
          comment: review.comment as String?,
          isVerified: review.isVerifiedBooking as bool,
          createdAt: review.createdAt as DateTime,
        ),
      );
}
