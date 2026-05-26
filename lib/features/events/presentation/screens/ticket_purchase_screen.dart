import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/presentation/blocs/ticket_purchase/ticket_purchase_bloc.dart';
import 'package:vibyuk/features/events/presentation/widgets/ticket_type_card.dart';

class TicketPurchaseScreen extends StatefulWidget {
  final EventEntity event;
  const TicketPurchaseScreen({super.key, required this.event});

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TicketPurchaseBloc>()
          .add(TicketPurchaseEventLoaded(event: widget.event));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Tickets')),
      body: BlocConsumer<TicketPurchaseBloc, TicketPurchaseState>(
        listener: (context, state) {
          if (state is TicketPurchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Purchase successful! Check My Tickets.'),
                backgroundColor: Colors.green,
              ),
            );
            context.go(RouteNames.myTickets);
          }
          if (state is TicketPurchaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TicketPurchaseInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final quantities = state is TicketPurchaseReady
              ? state.quantities
              : state is TicketPurchaseError
                  ? state.quantities
                  : <String, int>{};
          final event = state is TicketPurchaseReady
              ? state.event
              : state is TicketPurchaseError
                  ? state.event
                  : widget.event;
          final isProcessing =
              state is TicketPurchaseReady && state.isProcessing;
          final totalAmount = state is TicketPurchaseReady
              ? state.totalAmount
              : 0.0;
          final totalTickets = state is TicketPurchaseReady
              ? state.totalTickets
              : 0;
          final canPurchase =
              state is TicketPurchaseReady && state.canPurchase;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: event.ticketTypes
                      .where((t) => t.isVisible)
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TicketTypeCard(
                              ticketType: t,
                              quantity: quantities[t.id] ?? 0,
                              onAdd: () => context
                                  .read<TicketPurchaseBloc>()
                                  .add(TicketQuantityUpdated(
                                    ticketTypeId: t.id,
                                    quantity: (quantities[t.id] ?? 0) + 1,
                                  )),
                              onRemove: () {
                                final current = quantities[t.id] ?? 0;
                                if (current > 0) {
                                  context
                                      .read<TicketPurchaseBloc>()
                                      .add(TicketQuantityUpdated(
                                        ticketTypeId: t.id,
                                        quantity: current - 1,
                                      ));
                                }
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              _PurchaseSummaryBar(
                totalAmount: totalAmount,
                totalTickets: totalTickets,
                canPurchase: canPurchase,
                isProcessing: isProcessing,
                onPurchase: () => _onPurchase(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onPurchase(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your payment method ID to complete purchase:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'e.g. pm_test_xxxx',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop(controller.text.trim());
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    ).then((paymentMethodId) {
      if (paymentMethodId != null && paymentMethodId.isNotEmpty && mounted) {
        context.read<TicketPurchaseBloc>().add(
              TicketPurchaseSubmitted(paymentMethodId: paymentMethodId),
            );
      }
    });
  }
}

class _PurchaseSummaryBar extends StatelessWidget {
  final double totalAmount;
  final int totalTickets;
  final bool canPurchase;
  final bool isProcessing;
  final VoidCallback onPurchase;

  const _PurchaseSummaryBar({
    required this.totalAmount,
    required this.totalTickets,
    required this.canPurchase,
    required this.isProcessing,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(symbol: '₹', decimalDigits: 2)
        .format(totalAmount);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$totalTickets ticket${totalTickets == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  totalAmount == 0 ? 'Free' : formatted,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: (canPurchase && !isProcessing) ? onPurchase : null,
            child: isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}
