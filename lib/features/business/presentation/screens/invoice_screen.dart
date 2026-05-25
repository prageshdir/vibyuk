import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/invoice_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/invoice/invoice_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/invoice_card.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InvoiceBloc>()..add(LoadInvoiceEvent(bookingId)),
      child: const _InvoiceView(),
    );
  }
}

class _InvoiceView extends StatelessWidget {
  const _InvoiceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GST Invoice',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
      ),
      body: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceLoadedState && state.pdfUrl != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF available: ${state.pdfUrl}'),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InvoiceLoadingState) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is InvoiceErrorState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.failure.message,
                      style:
                          const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          if (state is InvoiceLoadedState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _GstCard(
                            title: 'From',
                            details: state.invoice.issuerGst,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GstCard(
                            title: 'To',
                            details: state.invoice.recipientGst,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InvoiceCard(
                    invoice: state.invoice,
                    isLoadingPdf: state.isLoadingPdf,
                    onDownload: () => context
                        .read<InvoiceBloc>()
                        .add(LoadInvoicePdfUrlEvent(state.invoice.id)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _GstCard extends StatelessWidget {
  const _GstCard({required this.title, required this.details});
  final String title;
  final GstDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceVariant,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Text(details.legalName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            Text(details.gstin,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
