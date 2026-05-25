import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';
import 'package:vibyuk/features/events/presentation/widgets/ticket_quantity_selector.dart';

class TicketTypeCard extends StatelessWidget {
  const TicketTypeCard({
    super.key,
    required this.ticketType,
    required this.quantity,
    this.onAdd,
    this.onRemove,
    this.isReadOnly = false,
  });

  final TicketTypeEntity ticketType;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final bool isReadOnly;

  Color _tierColor() {
    switch (ticketType.tier) {
      case TicketTier.free:
        return Colors.green;
      case TicketTier.standard:
        return Colors.blue;
      case TicketTier.vip:
        return Colors.purple;
      case TicketTier.vvip:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tierColor = _tierColor();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tier color strip
            Container(width: 4, color: tierColor),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticketType.name,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (ticketType.description != null &&
                                  ticketType.description!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  ticketType.description!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRightSection(context),
                      ],
                    ),

                    // Perks
                    if (ticketType.perks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _PerksRow(perks: ticketType.perks),
                    ],

                    const SizedBox(height: 8),

                    // Price + availability
                    Row(
                      children: [
                        Text(
                          ticketType.isFree
                              ? 'Free'
                              : NumberFormat.currency(
                                  symbol: '${ticketType.currency} ',
                                  decimalDigits: 2,
                                ).format(ticketType.price),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ticketType.isFree
                                ? Colors.green
                                : colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        _AvailabilityText(ticketType: ticketType),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSection(BuildContext context) {
    if (ticketType.isSoldOut) {
      return _StatusBadge(label: 'Sold Out', color: Colors.red);
    }
    if (!ticketType.isSaleActive) {
      return Text(
        'Sale ended',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    if (!isReadOnly) {
      return TicketQuantitySelector(
        quantity: quantity,
        max: ticketType.maxPerOrder,
        onIncrement: onAdd,
        onDecrement: onRemove,
      );
    }
    return const SizedBox.shrink();
  }
}

class _PerksRow extends StatelessWidget {
  const _PerksRow({required this.perks});

  final List<String> perks;

  @override
  Widget build(BuildContext context) {
    final visible = perks.take(3).toList();
    final extra = perks.length - visible.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...visible.map(
          (perk) => Chip(
            label: Text(perk, style: const TextStyle(fontSize: 10)),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        if (extra > 0)
          Chip(
            label: Text('+$extra more', style: const TextStyle(fontSize: 10)),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _AvailabilityText extends StatelessWidget {
  const _AvailabilityText({required this.ticketType});

  final TicketTypeEntity ticketType;

  @override
  Widget build(BuildContext context) {
    final available = ticketType.availableQuantity;
    final isLow = available < 10;

    return Text(
      '$available left',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: isLow ? Colors.orange : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
