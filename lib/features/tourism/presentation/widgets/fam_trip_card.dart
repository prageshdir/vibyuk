import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';

class FamTripCard extends StatelessWidget {
  const FamTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onApply,
  });

  final FamTripEntity trip;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(context),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  const SizedBox(height: 8),
                  _buildDateRow(context),
                  const SizedBox(height: 10),
                  _buildPerksRow(context),
                  const SizedBox(height: 10),
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 7,
            child: trip.coverImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: trip.coverImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.shimmerBase),
                    errorWidget: (_, __, ___) => _coverPlaceholder(),
                  )
                : _coverPlaceholder(),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: _StatusBadge(status: trip.status),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _SpotsBadge(spotsRemaining: trip.spotsRemaining),
        ),
      ],
    );
  }

  Widget _coverPlaceholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2B5EFF), Color(0xFF00D9C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            const Icon(Icons.flight_takeoff, color: Colors.white38, size: 48),
      );

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trip.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'by ${trip.organizerName}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today_outlined,
            size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          '${_formatDate(trip.departureDate)} – ${_formatDate(trip.returnDate)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${trip.durationDays}D',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        if (trip.isOpen)
          Text(
            '${trip.daysUntilDeparture}d away',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );
  }

  Widget _buildPerksRow(BuildContext context) {
    if (trip.perks.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: trip.perks.take(3).map((perk) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            perk,
            style: const TextStyle(
              color: AppColors.onTertiaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trip.requiredFollowerCount ~/ 1000}K+',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
            ),
            Text(
              'Min. followers',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const Spacer(),
        if (trip.isOpen && onApply != null)
          FilledButton(
            onPressed: onApply,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply Now',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day} ${_monthAbbr(date.month)}';

  String _monthAbbr(int month) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][month - 1];
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final FamTripStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      FamTripStatus.upcoming => ('UPCOMING', AppColors.primary),
      FamTripStatus.inProgress => ('IN PROGRESS', AppColors.tertiary),
      FamTripStatus.completed => ('COMPLETED', AppColors.textSecondary),
      FamTripStatus.cancelled => ('CANCELLED', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SpotsBadge extends StatelessWidget {
  const _SpotsBadge({required this.spotsRemaining});

  final int spotsRemaining;

  @override
  Widget build(BuildContext context) {
    final isFull = spotsRemaining == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFull ? Colors.black54 : AppColors.success.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isFull ? 'FULL' : '$spotsRemaining spots',
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
