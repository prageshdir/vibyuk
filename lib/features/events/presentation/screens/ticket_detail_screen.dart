import 'package:flutter/material.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/presentation/widgets/qr_ticket_widget.dart';
import 'package:vibyuk/features/events/presentation/widgets/refund_dialog.dart';

class TicketDetailScreen extends StatelessWidget {
  final TicketEntity ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ticket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing ticket...')),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  QrTicketWidget(ticket: ticket, showDetails: true),
                  const SizedBox(height: 24),
                  if (ticket.canRefund)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _showRefundDialog(context),
                      icon: const Icon(Icons.money_off_outlined),
                      label: const Text('Request Refund'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => RefundDialog(
        ticketId: ticket.id,
        ticketTypeName: ticket.ticketTypeName,
        amount: ticket.paidAmount,
        currency: ticket.currency,
        onConfirm: (reason) {
          // Refund request submitted — in a full implementation this would
          // call RequestRefundUseCase via a cubit or BLoC.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refund request submitted. Processing in 5–10 days.'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
