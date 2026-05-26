import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/creator/presentation/blocs/bank_account/bank_account_bloc.dart';

class CreatorBankAccountScreen extends StatefulWidget {
  const CreatorBankAccountScreen({super.key});

  @override
  State<CreatorBankAccountScreen> createState() =>
      _CreatorBankAccountScreenState();
}

class _CreatorBankAccountScreenState extends State<CreatorBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _confirmAccountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();

  @override
  void dispose() {
    _accountHolderCtrl.dispose();
    _accountNumberCtrl.dispose();
    _confirmAccountCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    super.dispose();
  }

  String? _validateIfsc(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final clean = v.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(clean)) {
      return 'Invalid IFSC (e.g. SBIN0001234)';
    }
    return null;
  }

  String? _validateAccountNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (v.trim().length < 9 || v.trim().length > 18) {
      return 'Account number must be 9–18 digits';
    }
    return null;
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_accountNumberCtrl.text.trim() != _confirmAccountCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account numbers do not match')),
      );
      return;
    }
    context.read<BankAccountBloc>().add(SaveBankAccountEvent(
          accountHolderName: _accountHolderCtrl.text.trim(),
          accountNumber: _accountNumberCtrl.text.trim(),
          ifscCode: _ifscCtrl.text.trim().toUpperCase(),
          bankName: _bankNameCtrl.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<BankAccountBloc, BankAccountState>(
      listener: (context, state) {
        if (state is BankAccountLoadedState && state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bank account details saved'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state is BankAccountErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bank Account',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: BlocBuilder<BankAccountBloc, BankAccountState>(
          builder: (context, state) {
            final isSaving =
                state is BankAccountLoadedState && state.isSaving;
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (state is BankAccountLoadedState &&
                      state.account != null)
                    _SavedAccountBanner(
                        account: state.account!,
                        theme: theme),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: theme.colorScheme.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your payout will be transferred via NEFT/IMPS. '
                            'TDS at 1% (Sec 194O) is deducted before transfer.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Account Details',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _accountHolderCtrl,
                    label: 'Account Holder Name',
                    hint: 'As per bank records',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _accountNumberCtrl,
                    label: 'Account Number',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: _validateAccountNumber,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmAccountCtrl,
                    label: 'Confirm Account Number',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: _validateAccountNumber,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _ifscCtrl,
                    label: 'IFSC Code',
                    hint: 'e.g. SBIN0001234',
                    validator: _validateIfsc,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _bankNameCtrl,
                    label: 'Bank Name',
                    hint: 'e.g. State Bank of India',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: isSaving ? null : () => _save(context),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52)),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Bank Account'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SavedAccountBanner extends StatelessWidget {
  const _SavedAccountBanner({required this.account, required this.theme});
  final dynamic account;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved account: ${account.bankName}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                    '${account.accountHolderName} · ****${account.accountNumberLast4} · ${account.ifscCode}',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (account.isVerified)
            const Chip(
              label: Text('Verified',
                  style: TextStyle(fontSize: 11, color: Colors.green)),
              backgroundColor: Colors.transparent,
              side: BorderSide(color: Colors.green),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
