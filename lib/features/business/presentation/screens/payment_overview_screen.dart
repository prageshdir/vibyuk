import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/payment/payment_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';
import 'package:vibyuk/features/business/presentation/widgets/payment_tile.dart';

class PaymentOverviewScreen extends StatefulWidget {
  const PaymentOverviewScreen({super.key});

  @override
  State<PaymentOverviewScreen> createState() => _PaymentOverviewScreenState();
}

class _PaymentOverviewScreenState extends State<PaymentOverviewScreen> {
  final _scrollController = ScrollController();
  PaymentStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const LoadPaymentsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<PaymentBloc>().add(const LoadMorePaymentsEvent());
    }
  }

  void _applyFilter(PaymentStatus? status) {
    setState(() => _statusFilter = status);
    context
        .read<PaymentBloc>()
        .add(FilterPaymentsByStatusEvent(status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.transactionHistory),
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Transaction History',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _StatusFilterBar(
            selected: _statusFilter,
            onSelected: _applyFilter,
          ),
        ),
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) => switch (state) {
          PaymentLoadingState() => const Center(child: AppLoader()),
          PaymentsLoadedState(:final payments, :final isLoadingMore) =>
            payments.isEmpty
                ? const BusinessEmptyState.noPayments()
                : Column(
                    children: [
                      _SummaryBanner(payments: payments),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          itemCount:
                              payments.length + (isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 68),
                          itemBuilder: (context, index) {
                            if (index == payments.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: AppLoader(size: 24)),
                              );
                            }
                            return PaymentTile(
                              payment: payments[index],
                              onTap: () => context.push(
                                RouteNames.paymentDetail,
                                extra: payments[index],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          PaymentErrorState(:final failure) => BusinessEmptyState(
              title: 'Failed to load payments',
              description: failure.message,
              icon: Icons.payments_rounded,
              actionLabel: 'Retry',
              onAction: () => context
                  .read<PaymentBloc>()
                  .add(const RefreshPaymentsEvent()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.selected, required this.onSelected});
  final PaymentStatus? selected;
  final void Function(PaymentStatus?) onSelected;

  @override
  Widget build(BuildContext context) {
    final statuses = [null, ...PaymentStatus.values];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final status = statuses[i];
          final label = status?.label ?? 'All';
          final isSelected = selected == status;
          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(status),
            selectedColor: AppColors.primaryContainer,
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final List payments;
  const _SummaryBanner({required this.payments});

  @override
  Widget build(BuildContext context) {
    final completed =
        payments.where((p) => p.status.name == 'completed').toList();
    final totalSpend =
        completed.fold<double>(0.0, (sum, p) => sum + (p.amount as double));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total spent',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '£${totalSpend.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Transactions',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${completed.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
