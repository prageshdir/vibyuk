import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/create_campaign_use_case.dart';
import 'package:vibyuk/features/business/presentation/blocs/campaign/campaign_bloc.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1 - Basic info
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  CampaignType _campaignType = CampaignType.standard;

  // Step 2 - Budget & dates
  final _budgetCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _targetCreators = 1;

  // Step 3 - Categories
  final _selectedCategories = <String>[];

  static const _categories = [
    'Photography', 'Videography', 'Influencer', 'Music',
    'Fitness', 'Beauty', 'Tech', 'Food', 'Travel', 'Lifestyle',
    'Fashion', 'Gaming', 'Sports', 'Comedy',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CampaignBloc, CampaignState>(
      listener: (context, state) {
        if (state is CampaignCreatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campaign created!')),
          );
          context.pop();
        }
        if (state is CampaignErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('New Campaign',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: Column(
          children: [
            _StepIndicator(currentStep: _step, totalSteps: 3),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: switch (_step) {
                    0 => _Step1(
                        titleCtrl: _titleCtrl,
                        descCtrl: _descCtrl,
                        campaignType: _campaignType,
                        onCampaignTypeChanged: (t) =>
                            setState(() => _campaignType = t),
                      ),
                    1 => _Step2(
                        budgetCtrl: _budgetCtrl,
                        startDate: _startDate,
                        endDate: _endDate,
                        targetCreators: _targetCreators,
                        onStartDate: (d) =>
                            setState(() => _startDate = d),
                        onEndDate: (d) => setState(() => _endDate = d),
                        onCreatorsChanged: (v) =>
                            setState(() => _targetCreators = v),
                      ),
                    _ => _Step3(
                        categories: _categories,
                        selected: _selectedCategories,
                        onToggle: (cat) => setState(() {
                          if (_selectedCategories.contains(cat)) {
                            _selectedCategories.remove(cat);
                          } else {
                            _selectedCategories.add(cat);
                          }
                        }),
                      ),
                  },
                ),
              ),
            ),
            _BottomNav(
              step: _step,
              isLoading: state is CampaignLoadingState,
              onBack: _step > 0 ? () => setState(() => _step--) : null,
              onNext: _onNext,
            ),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    _submit();
  }

  void _submit() {
    if (_titleCtrl.text.isEmpty || _budgetCtrl.text.isEmpty) return;
    final budget = double.tryParse(_budgetCtrl.text);
    if (budget == null) return;
    if (_startDate == null) return;

    context.read<CampaignBloc>().add(
          CreateCampaignEvent(
            params: CreateCampaignParams(
              title: _titleCtrl.text.trim(),
              description: _descCtrl.text.trim().isEmpty
                  ? null
                  : _descCtrl.text.trim(),
              budget: budget,
              campaignType: _campaignType,
              startDate: _startDate!,
              endDate: _endDate,
              categories: _selectedCategories,
              targetCreatorCount: _targetCreators,
            ),
          ),
        );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepIndicator(
      {required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: (i ~/ 2) < currentStep
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            );
          }
          final step = i ~/ 2;
          final done = step < currentStep;
          final active = step == currentStep;
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done || active ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: done || active
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
          );
        }),
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final CampaignType campaignType;
  final ValueChanged<CampaignType> onCampaignTypeChanged;

  const _Step1({
    required this.titleCtrl,
    required this.descCtrl,
    required this.campaignType,
    required this.onCampaignTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Basic information'),
        const SizedBox(height: 16),
        AppTextField(
          controller: titleCtrl,
          label: 'Campaign title',
          hint: 'e.g. Summer collection launch',
          validator: (v) =>
              v == null || v.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: descCtrl,
          label: 'Description (optional)',
          hint: 'Describe your campaign goals...',
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        const _SectionTitle('Campaign type'),
        const SizedBox(height: 8),
        _CampaignTypeSelector(
          selected: campaignType,
          onChanged: onCampaignTypeChanged,
        ),
      ],
    );
  }
}

class _CampaignTypeSelector extends StatelessWidget {
  final CampaignType selected;
  final ValueChanged<CampaignType> onChanged;

  const _CampaignTypeSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: CampaignType.values.map((type) {
        final isSelected = selected == type;
        final (icon, subtitle) = switch (type) {
          CampaignType.standard => (
              Icons.campaign_rounded,
              'Open to all matching creators. Creators can apply to your campaign.',
            ),
          CampaignType.directBooking => (
              Icons.person_search_rounded,
              'Invite specific creators directly. Ideal for targeted collaborations.',
            ),
        };
        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? AppColors.primaryContainer.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Step2 extends StatelessWidget {
  final TextEditingController budgetCtrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final int targetCreators;
  final ValueChanged<DateTime> onStartDate;
  final ValueChanged<DateTime?> onEndDate;
  final ValueChanged<int> onCreatorsChanged;

  const _Step2({
    required this.budgetCtrl,
    required this.startDate,
    required this.endDate,
    required this.targetCreators,
    required this.onStartDate,
    required this.onEndDate,
    required this.onCreatorsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Budget & timeline'),
        const SizedBox(height: 16),
        AppTextField(
          controller: budgetCtrl,
          label: 'Total budget (₹)',
          hint: '0.00',
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Budget is required';
            if (double.tryParse(v) == null) return 'Enter a valid amount';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _DateField(
          label: 'Start date',
          date: startDate,
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (d != null) onStartDate(d);
          },
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'End date (optional)',
          date: endDate,
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate:
                  startDate?.add(const Duration(days: 7)) ?? DateTime.now(),
              firstDate: startDate ?? DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            onEndDate(d);
          },
        ),
        const SizedBox(height: 16),
        _CreatorCountField(
          value: targetCreators,
          onChanged: onCreatorsChanged,
        ),
      ],
    );
  }
}

class _Step3 extends StatelessWidget {
  final List<String> categories;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _Step3({
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Target categories'),
        const SizedBox(height: 4),
        Text(
          'Select the creator categories you want to target',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = selected.contains(cat);
            return FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => onToggle(cat),
              selectedColor: AppColors.primaryContainer,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  date != null
                      ? DateFormat('d MMM yyyy').format(date!)
                      : 'Select date',
                  style: TextStyle(
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                    fontWeight:
                        date != null ? FontWeight.w500 : FontWeight.w400,
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

class _CreatorCountField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CreatorCountField(
      {required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target creators',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text('How many creators do you want to book?',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              color: AppColors.primary,
            ),
            Text(
              '$value',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () => onChanged(value + 1),
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int step;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const _BottomNav({
    required this.step,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            if (onBack != null) ...[
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: PrimaryButton(
                label: step == 2 ? 'Create Campaign' : 'Next',
                onPressed: isLoading ? null : onNext,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
