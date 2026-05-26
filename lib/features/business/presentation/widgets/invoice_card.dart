import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/invoice_entity.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    this.onDownload,
    this.isLoadingPdf = false,
  });

  final InvoiceEntity invoice;
  final VoidCallback? onDownload;
  final bool isLoadingPdf;

  static final _fmt = DateFormat('d MMM y');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invoice ${invoice.invoiceNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                if (onDownload != null)
                  isLoadingPdf
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        )
                      : IconButton(
                          onPressed: onDownload,
                          icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                          tooltip: 'Download PDF',
                        ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Issued: ${_fmt.format(invoice.issuedAt)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const Divider(height: 20, color: AppColors.divider),
            ...invoice.lineItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.description,
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 20, color: AppColors.divider),
            _TaxRow('Subtotal', '₹${invoice.subtotal.toStringAsFixed(2)}'),
            if (!invoice.isInterState) ...[
              _TaxRow('CGST', '₹${invoice.totalCgst.toStringAsFixed(2)}'),
              _TaxRow('SGST', '₹${invoice.totalSgst.toStringAsFixed(2)}'),
            ] else
              _TaxRow('IGST', '₹${invoice.totalIgst.toStringAsFixed(2)}'),
            const Divider(height: 16, color: AppColors.divider),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text(
                  invoice.grandTotalDisplay,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaxRow extends StatelessWidget {
  const _TaxRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
