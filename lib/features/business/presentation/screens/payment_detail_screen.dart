import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/escrow/escrow_bloc.dart';
import 'package:vibyuk/features/business/presentation/blocs/invoice/invoice_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/escrow_status_card.dart';
import 'package:vibyuk/features/business/presentation/widgets/invoice_card.dart';

class PaymentDetailScreen extends StatelessWidget {
  const PaymentDetailScreen({super.key, required this.payment});
  final PaymentEntity payment;

  static final _fmt = DateFormat('d MMM y, h:mm a');

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        if (payment.bookingId != null)
          BlocProvider(
            create: (_) =>
                sl<EscrowBloc>()..add(LoadEscrowEvent(payment.bookingId!)),
          ),
        if (payment.bookingId != null)
          BlocProvider(
            create: (_) =>
                sl<InvoiceBloc>()..add(LoadInvoiceEvent(payment.bookingId!)),
          ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Payment Details',
              style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.surface,
        ),
        body: ListView(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    payment.amountDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatusBadge(status: payment.status),
                  const SizedBox(height: 8),
                  Text(
                    payment.description,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: AppColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow('Payment ID', payment.id),
                      _DetailRow('Type', payment.type.label),
                      _DetailRow('Date', _fmt.format(payment.createdAt)),
                      if (payment.bookingId != null)
                        _DetailRow('Booking', payment.bookingId!),
                    ],
                  ),
                ),
              ),
            ),
            if (payment.bookingId != null)
              BlocBuilder<EscrowBloc, EscrowState>(
                builder: (context, state) {
                  if (state is EscrowLoadingState) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    );
                  }
                  if (state is EscrowLoadedState) {
                    return EscrowStatusCard(
                      escrow: state.escrow,
                      onRelease: state.escrow.status.isActive
                          ? () => context.read<EscrowBloc>().add(
                                ReleaseEscrowEvent(escrowId: state.escrow.id),
                              )
                          : null,
                      onRefund: state.escrow.status.isActive
                          ? () => _showRefundDialog(context, state.escrow.id)
                          : null,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            if (payment.bookingId != null)
              BlocBuilder<InvoiceBloc, InvoiceState>(
                builder: (context, state) {
                  if (state is InvoiceLoadedState) {
                    return InvoiceCard(
                      invoice: state.invoice,
                      isLoadingPdf: state.isLoadingPdf,
                      onDownload: state.invoice.id.isNotEmpty
                          ? () => context.read<InvoiceBloc>().add(
                                LoadInvoicePdfUrlEvent(state.invoice.id),
                              )
                          : null,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showRefundDialog(BuildContext context, String escrowId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Refund'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<EscrowBloc>().add(
                      RequestRefundEvent(
                        escrowId: escrowId,
                        reason: controller.text.trim(),
                      ),
                    );
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final PaymentStatus status;

  Color get _color => switch (status) {
        PaymentStatus.pending => AppColors.warning,
        PaymentStatus.completed => AppColors.success,
        PaymentStatus.failed => AppColors.error,
        PaymentStatus.refunded => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
