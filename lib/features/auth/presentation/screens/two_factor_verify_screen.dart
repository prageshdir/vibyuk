import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart' as route_names;
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';

class TwoFactorVerifyScreen extends StatefulWidget {
  const TwoFactorVerifyScreen({super.key, required this.method});

  final TwoFactorMethod method;

  @override
  State<TwoFactorVerifyScreen> createState() => _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends State<TwoFactorVerifyScreen> {
  final _codeController = TextEditingController();
  final _recoveryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showRecovery = false;

  @override
  void dispose() {
    _codeController.dispose();
    _recoveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Verification'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is TotpVerifiedState) {
            context.go(route_names.RouteNames.home);
          } else if (state is AuthenticatedState) {
            context.go(route_names.RouteNames.home);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.method == TwoFactorMethod.totp
                      ? Icons.security
                      : Icons.sms,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Verify your identity',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.method == TwoFactorMethod.totp
                      ? 'Enter the 6-digit code from your authenticator app.'
                      : 'Enter the 6-digit code sent to your phone.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                if (!_showRecovery) ...[
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: widget.method == TwoFactorMethod.totp
                          ? 'Authenticator code'
                          : 'SMS code',
                      hintText: '000000',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (v) {
                      if (v == null || v.length != 6) {
                        return 'Enter the 6-digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoadingState;
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          VerifyTotpEvent(
                                            token: _codeController.text.trim(),
                                          ),
                                        );
                                  }
                                },
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('Verify'),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _showRecovery = true),
                      child: const Text('Use a recovery code instead'),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _recoveryController,
                    decoration: const InputDecoration(
                      labelText: 'Recovery code',
                      hintText: 'xxxxxxxx-xxxx-xxxx',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter a recovery code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoadingState;
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          VerifyTotpRecoveryEvent(
                                            recoveryCode:
                                                _recoveryController.text.trim(),
                                          ),
                                        );
                                  }
                                },
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('Verify with recovery code'),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _showRecovery = false),
                      child: const Text('Back to authenticator code'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
