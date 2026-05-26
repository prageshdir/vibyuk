import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';

class QrTicketWidget extends StatelessWidget {
  const QrTicketWidget({
    super.key,
    required this.ticket,
    this.showDetails = true,
  });

  final TicketEntity ticket;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TicketHeader(ticket: ticket),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    QrImageView(
                      data: ticket.qrData,
                      size: 200,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.orderRef,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                    if (!showDetails) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to expand',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showDetails) ...[
                const _DashedDivider(),
                _TicketDetails(ticket: ticket),
              ],
            ],
          ),
          if (ticket.status == TicketStatus.used)
            _BannerOverlay(label: 'CHECKED IN', color: Colors.green),
          if (ticket.status == TicketStatus.cancelled)
            _BannerOverlay(label: 'CANCELLED', color: Colors.red),
        ],
      ),
    );
  }
}

class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.ticket});

  final TicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        ticket.eventCoverUrl != null && ticket.eventCoverUrl!.isNotEmpty;

    return SizedBox(
      height: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            CachedNetworkImage(
              imageUrl: ticket.eventCoverUrl!,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => _GradientBackground(),
              errorWidget: (ctx, url, err) => _GradientBackground(),
            )
          else
            _GradientBackground(),
          // Dark scrim for legibility
          Container(color: Colors.black.withValues(alpha: 0.45)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.eventTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEE, MMM d • HH:mm').format(ticket.eventStartDate),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A0DAD), Color(0xFF3A0080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashedLinePainter(),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}

class _TicketDetails extends StatelessWidget {
  const _TicketDetails({required this.ticket});

  final TicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    final checkedInStr = ticket.checkedInAt != null
        ? DateFormat('MMM d, HH:mm').format(ticket.checkedInAt!)
        : 'Not yet';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailGrid(
            items: [
              _DetailItem(label: 'Ticket Type', value: ticket.ticketTypeName),
              _DetailItem(label: 'Name', value: ticket.ownerName),
              _DetailItem(
                label: 'Status',
                child: _StatusChip(status: ticket.status),
              ),
              _DetailItem(label: 'Checked In', value: checkedInStr),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String? value;
  final Widget? child;

  const _DetailItem({required this.label, this.value, this.child})
      : assert(value != null || child != null);
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.items});

  final List<_DetailItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        (items.length / 2).ceil(),
        (row) {
          final left = items[row * 2];
          final right = row * 2 + 1 < items.length ? items[row * 2 + 1] : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: _DetailCell(item: left)),
                if (right != null) Expanded(child: _DetailCell(item: right)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({required this.item});

  final _DetailItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        item.child ??
            Text(
              item.value!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TicketStatus status;

  Color _color() {
    switch (status) {
      case TicketStatus.active:
        return Colors.green;
      case TicketStatus.used:
        return Colors.blue;
      case TicketStatus.cancelled:
        return Colors.red;
      case TicketStatus.expired:
        return Colors.grey;
      case TicketStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _BannerOverlay extends StatelessWidget {
  const _BannerOverlay({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _BannerPainter(label: label, color: color),
        ),
      ),
    );
  }
}

class _BannerPainter extends CustomPainter {
  final String label;
  final Color color;

  _BannerPainter({required this.label, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.85);
    const bannerHeight = 40.0;
    final center = size.height / 2;

    canvas.drawRect(
      Rect.fromLTWH(0, center - bannerHeight / 2, size.width, bannerHeight),
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        center - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_BannerPainter oldDelegate) =>
      oldDelegate.label != label || oldDelegate.color != color;
}
