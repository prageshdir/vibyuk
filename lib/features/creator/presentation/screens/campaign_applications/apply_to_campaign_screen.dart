import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/creator/presentation/blocs/campaign_applications/campaign_applications_bloc.dart';

class ApplyToCampaignScreen extends StatefulWidget {
  const ApplyToCampaignScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  final String campaignId;
  final String campaignTitle;

  @override
  State<ApplyToCampaignScreen> createState() => _ApplyToCampaignScreenState();
}

class _ApplyToCampaignScreenState extends State<ApplyToCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  String _currency = 'GBP';

  static const _currencies = ['GBP', 'USD', 'EUR'];

  @override
  void dispose() {
    _coverLetterCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CampaignApplicationsBloc>().add(
          ApplyToCampaignEvent(
            campaignId: widget.campaignId,
            coverLetter: _coverLetterCtrl.text.trim().isEmpty
                ? null
                : _coverLetterCtrl.text.trim(),
            portfolioItemIds: const [],
            proposedRate: double.parse(_rateCtrl.text.trim()),
            currency: _currency,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply to Campaign',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<CampaignApplicationsBloc, CampaignApplicationsState>(
        listenWhen: (_, s) =>
            s is CampaignApplicationsLoadedState &&
            (s.submitSuccess || s.submitError != null),
        listener: (context, state) {
          if (state is CampaignApplicationsLoadedState) {
            if (state.submitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application submitted!')),
              );
              Navigator.pop(context);
            } else if (state.submitError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitError!.message)),
              );
            }
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CampaignApplicationsLoadedState &&
              state.isSubmitting;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Campaign header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign_outlined, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.campaignTitle,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Your Proposed Rate',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: _currencies
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _rateCtrl,
                        label: 'Amount',
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = double.tryParse(v.trim());
                          if (n == null || n <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                AppTextField(
                  controller: _coverLetterCtrl,
                  label: 'Cover Letter',
                  hint:
                      'Tell the brand why you\'re a great fit for this campaign…',
                  maxLines: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  'Optional — explain your approach, past relevant experience, or why this campaign aligns with your content.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                FilledButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Application'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
