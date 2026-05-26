import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_invoice_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/invoice/invoice_bloc.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<InvoiceBloc>()
        .add(LoadInvoiceEvent(bookingId: widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          BlocBuilder<InvoiceBloc, InvoiceState>(
            builder: (context, state) {
              if (state is InvoiceLoadedState &&
                  state.invoice.downloadUrl != null) {
                return IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () {},
                  tooltip: 'Download PDF',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, state) => switch (state) {
          InvoiceLoadingState() => const Center(child: AppLoader()),
          InvoiceLoadedState(:final invoice) => _InvoiceView(invoice: invoice),
          InvoiceErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<InvoiceBloc>().add(
                          LoadInvoiceEvent(bookingId: widget.bookingId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _InvoiceView extends StatelessWidget {
  const _InvoiceView({required this.invoice});

  final BookingInvoiceEntity invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) = _statusConfig(invoice.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INVOICE',
                          style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.5,
                              color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(invoice.invoiceNumber,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Parties
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PartyBlock(
                  title: 'From',
                  name: invoice.businessName,
                  address: invoice.businessAddress,
                  gstin: invoice.businessGstin,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PartyBlock(
                  title: 'To',
                  name: invoice.creatorName,
                  address: invoice.creatorAddress,
                  gstin: invoice.creatorGstin,
                ),
              ),
            ],
          ),
          if (invoice.placeOfSupply != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Place of supply: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                Text(invoice.placeOfSupply!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Dates
          Row(
            children: [
              Expanded(
                child: _DateChip(
                  label: 'Issued',
                  date: invoice.issuedAt,
                ),
              ),
              if (invoice.dueAt != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _DateChip(
                    label: 'Due',
                    date: invoice.dueAt!,
                    isAlert: invoice.isOverdue,
                  ),
                ),
              ],
              if (invoice.paidAt != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _DateChip(
                    label: 'Paid',
                    date: invoice.paidAt!,
                    isSuccess: true,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Line items
          Text('Line Items',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Table header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: Text('Description',
                              style: theme.textTheme.labelMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant))),
                      Expanded(
                          child: Text('Qty',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant))),
                      Expanded(
                          flex: 2,
                          child: Text('Total',
                              textAlign: TextAlign.right,
                              style: theme.textTheme.labelMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...invoice.lineItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 4,
                                child: Text(item.description,
                                    style: theme.textTheme.bodySmall)),
                            Expanded(
                                child: Text('${item.quantity}',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    '₹${item.total.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                      if (i < invoice.lineItems.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Totals
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _TotalRow(
                  label: 'Subtotal',
                  value: '₹${invoice.subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                if (invoice.hasGstBreakdown) ...[
                  if (invoice.isInterState) ...[
                    _TotalRow(
                      label: 'IGST (${(invoice.taxRate * 100).toStringAsFixed(0)}%)',
                      value: '₹${invoice.igst.toStringAsFixed(2)}',
                    ),
                  ] else ...[
                    _TotalRow(
                      label: 'CGST (${(invoice.taxRate * 50).toStringAsFixed(1)}%)',
                      value: '₹${invoice.cgst.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 6),
                    _TotalRow(
                      label: 'SGST (${(invoice.taxRate * 50).toStringAsFixed(1)}%)',
                      value: '₹${invoice.sgst.toStringAsFixed(2)}',
                    ),
                  ],
                ] else ...[
                  _TotalRow(
                    label: 'GST (${(invoice.taxRate * 100).toStringAsFixed(0)}%)',
                    value: '₹${invoice.taxAmount.toStringAsFixed(2)}',
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                _TotalRow(
                  label: 'Total',
                  value: '₹${invoice.total.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),

          if (invoice.notes != null) ...[
            const SizedBox(height: 20),
            Text('Notes',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(invoice.notes!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(height: 1.5)),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static (String, Color) _statusConfig(InvoiceStatus s) => switch (s) {
        InvoiceStatus.draft => ('Draft', Colors.grey),
        InvoiceStatus.issued => ('Issued', Colors.blue),
        InvoiceStatus.paid => ('Paid', Colors.green),
        InvoiceStatus.overdue => ('Overdue', Colors.red),
        InvoiceStatus.voided => ('Voided', Colors.grey),
      };
}

class _PartyBlock extends StatelessWidget {
  const _PartyBlock({
    required this.title,
    required this.name,
    this.address,
    this.gstin,
  });

  final String title;
  final String name;
  final String? address;
  final String? gstin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(name,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          if (address != null) ...[
            const SizedBox(height: 2),
            Text(address!,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
          if (gstin != null) ...[
            const SizedBox(height: 4),
            Text('GSTIN: $gstin',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace')),
          ],
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.date,
    this.isAlert = false,
    this.isSuccess = false,
  });

  final String label;
  final DateTime date;
  final bool isAlert;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isAlert
        ? Colors.red
        : isSuccess
            ? Colors.green
            : theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isAlert ? Colors.red : isSuccess ? Colors.green : Colors.grey)
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: color.withOpacity(0.7))),
          Text('${date.day}/${date.month}/${date.year}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.normal,
              )),
        ),
        Text(value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: isBold ? 16 : null,
            )),
      ],
    );
  }
}
