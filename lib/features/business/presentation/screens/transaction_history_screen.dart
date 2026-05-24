import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/transaction_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TransactionBloc>()..add(const LoadTransactionsEvent()),
      child: const _TransactionView(),
    );
  }
}

class _TransactionView extends StatefulWidget {
  const _TransactionView();

  @override
  State<_TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<_TransactionView> {
  final _scroll = ScrollController();
  TransactionType? _filter;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent * 0.85) {
      context.read<TransactionBloc>().add(const LoadMoreTransactionsEvent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _FilterChips(
            selected: _filter,
            onSelected: (type) {
              setState(() => _filter = type);
              context
                  .read<TransactionBloc>()
                  .add(FilterTransactionsByTypeEvent(type));
            },
          ),
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoadingState) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is TransactionErrorState) {
            return Center(
              child: Text(
                state.failure.message,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          if (state is TransactionsLoadedState) {
            if (state.transactions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: AppColors.outlineVariant),
                    SizedBox(height: 12),
                    Text('No transactions',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return ListView.separated(
              controller: _scroll,
              itemCount:
                  state.transactions.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, i) {
                if (i == state.transactions.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary)),
                  );
                }
                return TransactionCard(transaction: state.transactions[i]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});
  final TransactionType? selected;
  final void Function(TransactionType?) onSelected;

  @override
  Widget build(BuildContext context) {
    final types = [null, ...TransactionType.values];
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final type = types[i];
          final label = type?.label ?? 'All';
          final isSelected = selected == type;
          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(type),
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
