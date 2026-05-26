import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';

class BookingRequestCard extends StatelessWidget {
  const BookingRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onAccept,
    this.onDecline,
  });

  final BookingRequestEntity request;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  Color get _statusColor {
    return switch (request.status) {
      BookingRequestStatus.pending => Colors.orange,
      BookingRequestStatus.accepted => Colors.green,
      BookingRequestStatus.declined => Colors.red,
      BookingRequestStatus.counterOffered => Colors.blue,
      BookingRequestStatus.expired => Colors.grey,
      BookingRequestStatus.cancelled => Colors.grey,
    };
  }

  String get _statusLabel {
    return switch (request.status) {
      BookingRequestStatus.pending => 'Pending',
      BookingRequestStatus.accepted => 'Accepted',
      BookingRequestStatus.declined => 'Declined',
      BookingRequestStatus.counterOffered => 'Counter Offer',
      BookingRequestStatus.expired => 'Expired',
      BookingRequestStatus.cancelled => 'Cancelled',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: request.businessLogoUrl != null
                        ? NetworkImage(request.businessLogoUrl!)
                        : null,
                    child: request.businessLogoUrl == null
                        ? Text(request.businessName[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w700))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.businessName,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(request.campaignTitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  _StatusChip(
                      label: _statusLabel, color: _statusColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoItem(
                    icon: Icons.sell_outlined,
                    label: 'Package',
                    value: request.packageTitle,
                  ),
                  const SizedBox(width: 16),
                  _InfoItem(
                    icon: Icons.currency_pound_rounded,
                    label: 'Offer',
                    value:
                        '${request.currency} ${request.offeredPrice.toStringAsFixed(0)}',
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Delivery',
                    value:
                        '${request.requestedDeliveryDate.day}/${request.requestedDeliveryDate.month}/${request.requestedDeliveryDate.year}',
                  ),
                  if (request.isPending && !request.isExpired) ...[
                    const Spacer(),
                    Text(
                      'Expires ${_expiresIn(request.expiresAt)}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.orange),
                    ),
                  ],
                ],
              ),
              if (request.canRespond && onAccept != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onAccept,
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _expiresIn(DateTime expires) {
    final diff = expires.difference(DateTime.now());
    if (diff.inDays > 0) return 'in ${diff.inDays}d';
    if (diff.inHours > 0) return 'in ${diff.inHours}h';
    return 'soon';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem(
      {required this.icon, required this.label, required this.value, this.valueColor});
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10)),
            Text(value,
                style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor)),
          ],
        ),
      ],
    );
  }
}
