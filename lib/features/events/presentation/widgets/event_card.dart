import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/presentation/widgets/capacity_bar_widget.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final EventEntity event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CoverImage(event: event),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleDateRow(event: event, textTheme: textTheme),
                  const SizedBox(height: 6),
                  _LocationRow(event: event, colorScheme: colorScheme),
                  const SizedBox(height: 8),
                  _PriceCapacityRow(event: event, colorScheme: colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(),
          if (event.isFeatured) _FeaturedBadge(),
          _StatusBadge(status: event.status),
          if (event.isSoldOut) _SoldOutRibbon(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (event.coverImageUrl == null || event.coverImageUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
      );
    }
    return CachedNetworkImage(
      imageUrl: event.coverImageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 12, color: Colors.black87),
            SizedBox(width: 2),
            Text(
              'Featured',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final EventStatus status;

  Color _statusColor() {
    switch (status) {
      case EventStatus.published:
        return Colors.green;
      case EventStatus.draft:
        return Colors.orange;
      case EventStatus.cancelled:
        return Colors.red;
      case EventStatus.completed:
        return Colors.blueGrey;
      case EventStatus.postponed:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor().withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SoldOutRibbon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        color: Colors.red.withOpacity(0.85),
        child: const Text(
          'SOLD OUT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _TitleDateRow extends StatelessWidget {
  const _TitleDateRow({required this.event, required this.textTheme});

  final EventEntity event;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d • HH:mm').format(event.startDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.event, required this.colorScheme});

  final EventEntity event;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          event.isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            event.venueName,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PriceCapacityRow extends StatelessWidget {
  const _PriceCapacityRow({required this.event, required this.colorScheme});

  final EventEntity event;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final minPrice = event.minTicketPrice;
    final priceText = (minPrice == null || minPrice == 0)
        ? 'Free'
        : 'From ${NumberFormat.currency(symbol: '${event.currency} ', decimalDigits: 2).format(minPrice)}';
    final isFree = minPrice == null || minPrice == 0;

    return Row(
      children: [
        Text(
          priceText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isFree ? Colors.green : colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 80,
          child: CapacityBarWidget(
            sold: event.soldTickets,
            total: event.totalCapacity,
            compact: true,
          ),
        ),
      ],
    );
  }
}
