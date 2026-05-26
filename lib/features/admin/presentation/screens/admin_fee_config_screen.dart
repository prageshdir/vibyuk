import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';

class AdminFeeConfigScreen extends StatefulWidget {
  const AdminFeeConfigScreen({super.key});

  @override
  State<AdminFeeConfigScreen> createState() => _AdminFeeConfigScreenState();
}

class _AdminFeeConfigScreenState extends State<AdminFeeConfigScreen> {
  late final Map<BusinessPlan, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final plan in BusinessPlan.values)
        plan: TextEditingController(
          text: plan.commissionRate.toStringAsFixed(0),
        ),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Fee Configuration'),
        backgroundColor: AppColors.electricViolet,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.electricViolet,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(77),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Commission rates apply to all transactions on that plan. '
                      'Changes take effect immediately for new bookings.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Commission Rates by Plan',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...BusinessPlan.values.map((plan) => _PlanFeeCard(
                  plan: plan,
                  controller: _controllers[plan]!,
                )),
            const SizedBox(height: 24),
            _RevenueImpactCard(controllers: _controllers),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // In production, call admin fee config API
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commission rates updated successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _PlanFeeCard extends StatelessWidget {
  const _PlanFeeCard({required this.plan, required this.controller});

  final BusinessPlan plan;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _planColor(plan);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.layers_outlined, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.displayName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    plan.isPaid
                        ? '${plan.formattedPrice}/mo'
                        : 'Free tier',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  suffixText: '%',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,1}')),
                ],
                textAlign: TextAlign.center,
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null) return 'Invalid';
                  if (d < 0 || d > 50) return '0–50%';
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _planColor(BusinessPlan plan) => switch (plan) {
        BusinessPlan.free => Colors.grey,
        BusinessPlan.starter => AppColors.primary,
        BusinessPlan.professional => AppColors.electricViolet,
        BusinessPlan.enterprise => const Color(0xFFFFB020),
      };
}

class _RevenueImpactCard extends StatelessWidget {
  const _RevenueImpactCard({required this.controllers});

  final Map<BusinessPlan, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate Summary',
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...BusinessPlan.values.map((plan) {
            final rate = controllers[plan]?.text ?? '0';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plan.displayName, style: theme.textTheme.bodySmall),
                  Text('$rate% commission',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
