import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/features/auth/domain/entities/totp_setup_entity.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const GetTotpSetupEvent());
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Set up Two-Factor Authentication')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is TotpEnabledState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Two-factor authentication enabled'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TotpSetupLoadedState) {
            return _SetupContent(
              setup: state.totpSetup,
              codeController: _codeController,
              formKey: _formKey,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SetupContent extends StatelessWidget {
  const _SetupContent({
    required this.setup,
    required this.codeController,
    required this.formKey,
  });

  final TotpSetupEntity setup;
  final TextEditingController codeController;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1: Install an authenticator app',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Install Google Authenticator or Authy on your phone.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text('Step 2: Scan the QR code or enter the key',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // QR code placeholder — production would use qr_flutter package
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2,
                              size: 80, color: theme.colorScheme.primary),
                          const SizedBox(height: 4),
                          Text('QR Code',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Or enter this key manually:',
                      style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          setup.secret,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: setup.secret));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Secret key copied')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (setup.recoveryCodes.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Recovery codes',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Save these codes in a safe place. Each can be used once if you lose access to your authenticator app.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: (setup.recoveryCodes as List<String>)
                      .map((code) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(code,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                )),
                          ))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('Step 3: Enter the verification code',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: '6-digit code',
                hintText: '000000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) {
                if (v == null || v.length != 6) return 'Enter the 6-digit code';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context
                        .read<AuthBloc>()
                        .add(EnableTotpEvent(totpCode: codeController.text.trim()));
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Enable Two-Factor Authentication'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
