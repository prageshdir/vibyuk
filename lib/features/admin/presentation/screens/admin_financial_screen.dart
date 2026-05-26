import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class AdminFinancialScreen extends StatefulWidget {
  const AdminFinancialScreen({super.key});

  @override
  State<AdminFinancialScreen> createState() => _AdminFinancialScreenState();
}

class _AdminFinancialScreenState extends State<AdminFinancialScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Management'),
        backgroundColor: AppColors.electricViolet,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pending Payouts'),
            Tab(text: 'Commission Ledger'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingPayoutsTab(
            onApprove: (id) => _handlePayout(context, id, approved: true),
            onReject: (id) => _handlePayout(context, id, approved: false),
          ),
          const _CommissionLedgerTab(),
        ],
      ),
    );
  }

  void _handlePayout(BuildContext context, String id, {required bool approved}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approved
            ? 'Payout $id approved'
            : 'Payout $id rejected'),
        backgroundColor: approved ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _PendingPayoutsTab extends StatelessWidget {
  const _PendingPayoutsTab({required this.onApprove, required this.onReject});

  final void Function(String id) onApprove;
  final void Function(String id) onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              _SummaryChip(
                  label: 'Pending',
                  value: currency.format(142500),
                  color: AppColors.warning),
              const SizedBox(width: 12),
              _SummaryChip(
                  label: 'Approved Today',
                  value: currency.format(65000),
                  color: AppColors.success),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _mockPayouts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final payout = _mockPayouts[i];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: theme.colorScheme.outline.withAlpha(51)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withAlpha(26),
                            child: Text(
                              (payout['creator'] as String)[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(payout['creator'] as String,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                Text(payout['bank'] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Text(
                            currency.format(payout['amount']),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(payout['date'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () =>
                                onReject(payout['id'] as String),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Reject',
                                style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () =>
                                onApprove(payout['id'] as String),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Approve',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CommissionLedgerTab extends StatelessWidget {
  const _CommissionLedgerTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              _SummaryChip(
                  label: 'This Month',
                  value: currency.format(284200),
                  color: AppColors.electricViolet),
              const SizedBox(width: 12),
              _SummaryChip(
                  label: 'Total',
                  value: currency.format(1840500),
                  color: AppColors.success),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _mockLedger.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final entry = _mockLedger[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.electricViolet.withAlpha(26),
                  child: Icon(Icons.receipt_long,
                      color: AppColors.electricViolet, size: 16),
                ),
                title: Text(
                  entry['booking'] as String,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${entry["plan"]} plan · ${entry["rate"]}% · ${entry["date"]}',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Text(
                  currency.format(entry['commission']),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
        Text(value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
      ],
    );
  }
}

final _mockPayouts = [
  {
    'id': 'pay_001',
    'creator': 'Priya Sharma',
    'bank': 'HDFC Bank ••••6789',
    'amount': 45000,
    'date': 'Requested 24 May 2026',
  },
  {
    'id': 'pay_002',
    'creator': 'Arjun Mehta',
    'bank': 'SBI ••••2345',
    'amount': 28500,
    'date': 'Requested 23 May 2026',
  },
  {
    'id': 'pay_003',
    'creator': 'Neha Kapoor',
    'bank': 'ICICI ••••9012',
    'amount': 69000,
    'date': 'Requested 22 May 2026',
  },
];

final _mockLedger = [
  {
    'booking': 'BKG-2026-0547',
    'plan': 'Professional',
    'rate': 12,
    'commission': 3600,
    'date': '25 May 2026',
  },
  {
    'booking': 'BKG-2026-0546',
    'plan': 'Starter',
    'rate': 15,
    'commission': 2250,
    'date': '25 May 2026',
  },
  {
    'booking': 'BKG-2026-0545',
    'plan': 'Enterprise',
    'rate': 10,
    'commission': 8000,
    'date': '24 May 2026',
  },
  {
    'booking': 'BKG-2026-0544',
    'plan': 'Free',
    'rate': 18,
    'commission': 1440,
    'date': '24 May 2026',
  },
  {
    'booking': 'BKG-2026-0543',
    'plan': 'Professional',
    'rate': 12,
    'commission': 4800,
    'date': '23 May 2026',
  },
];
