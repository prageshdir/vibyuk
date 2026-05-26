import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/budget_tracker/budget_tracker_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/budget_category_card.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/budget_pie_chart.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/wedding_progress_ring.dart';

class BudgetTrackerScreen extends StatefulWidget {
  final String weddingId;
  const BudgetTrackerScreen({super.key, required this.weddingId});

  @override
  State<BudgetTrackerScreen> createState() => _BudgetTrackerScreenState();
}

class _BudgetTrackerScreenState extends State<BudgetTrackerScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<BudgetTrackerBloc>()
        .add(BudgetTrackerLoadRequested(weddingId: widget.weddingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<BudgetTrackerBloc>()
                .add(const BudgetTrackerRefreshRequested()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<BudgetTrackerBloc, BudgetTrackerState>(
        builder: (context, state) => switch (state) {
          BudgetTrackerInitial() ||
          BudgetTrackerLoading() =>
            const Center(child: CircularProgressIndicator()),
          BudgetTrackerError(:final failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(failure.message),
                  ElevatedButton(
                    onPressed: () => context.read<BudgetTrackerBloc>().add(
                          BudgetTrackerLoadRequested(weddingId: widget.weddingId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          BudgetTrackerLoaded(:final budget) => _BudgetBody(budget: budget),
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final cats = ['venue', 'catering', 'photography', 'videography', 'flowers', 'music', 'attire', 'beauty', 'stationery', 'transport', 'honeymoon', 'other'];
    String selectedCategory = cats.first;
    final descCtrl = TextEditingController();
    final estCtrl = TextEditingController();
    final actCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Budget Item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: cats
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedCategory = v ?? cats.first),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description *'),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: estCtrl,
                    decoration: const InputDecoration(labelText: 'Estimated Amount *'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty == true) return 'Required';
                      if (double.tryParse(v!) == null) return 'Invalid';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: actCtrl,
                    decoration: const InputDecoration(labelText: 'Actual Amount'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                context.read<BudgetTrackerBloc>().add(BudgetTrackerItemAdded(
                      category: selectedCategory,
                      description: descCtrl.text,
                      estimatedAmount: double.parse(estCtrl.text),
                      actualAmount: actCtrl.text.isEmpty
                          ? 0
                          : double.tryParse(actCtrl.text) ?? 0,
                    ));
                Navigator.of(ctx).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetBody extends StatelessWidget {
  final dynamic budget;
  const _BudgetBody({required this.budget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = <String>{};
    for (final item in budget.items) {
      categories.add(item.category as String);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WeddingProgressRing(
                      progress: (budget.spentPercentage as double) / 100,
                      label: '${(budget.spentPercentage as double).toStringAsFixed(0)}%',
                      sublabel: 'Spent',
                      size: 100,
                      color: (budget.spentPercentage as double) > 90
                          ? Colors.red
                          : (budget.spentPercentage as double) > 70
                              ? Colors.orange
                              : Colors.green,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryLine(label: 'Budget', value: budget.totalBudget as double, theme: theme),
                        _SummaryLine(label: 'Estimated', value: budget.totalEstimated as double, theme: theme),
                        _SummaryLine(
                          label: 'Spent',
                          value: budget.totalActual as double,
                          theme: theme,
                          highlight: true,
                        ),
                        _SummaryLine(
                          label: 'Remaining',
                          value: budget.remainingBudget as double,
                          theme: theme,
                          color: (budget.remainingBudget as double) < 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                BudgetPieChart(
                  budgetByCategory: Map<String, double>.from(budget.actualByCategory as Map),
                  totalBudget: budget.totalBudget as double,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('By Category', style: theme.textTheme.titleMedium),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final cat = categories.elementAt(i);
              final items = (budget.items as List)
                  .where((item) => item.category == cat)
                  .toList();
              return BudgetCategoryCard(
                category: cat,
                items: items.cast(),
                onAddItem: () {},
              );
            },
            childCount: categories.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final double value;
  final ThemeData theme;
  final bool highlight;
  final Color? color;
  const _SummaryLine({
    required this.label,
    required this.value,
    required this.theme,
    this.highlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
