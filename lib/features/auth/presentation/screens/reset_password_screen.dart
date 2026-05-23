import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/utils/validators/form_validators.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/auth/presentation/widgets/password_strength_indicator.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _password = '';
  bool _resetSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ResetPasswordEvent(
            token: widget.token,
            password: _passwordController.text,
            passwordConfirmation: _confirmController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case PasswordResetSuccessState():
            setState(() => _resetSuccess = true);
          case AuthErrorState(:final failure):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.go(RouteNames.login),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoadingState;

              if (_resetSuccess) {
                return _ResetSuccessView(
                  onBackToLogin: () => context.go(RouteNames.login),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.lock_open_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reset password',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your new password below.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _passwordController,
                            label: 'New password',
                            hint: '••••••••',
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            validator: FormValidators.password,
                            onChanged: (v) => setState(() => _password = v),
                          ),
                          PasswordStrengthIndicator(password: _password),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _confirmController,
                            label: 'Confirm new password',
                            hint: '••••••••',
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            validator: FormValidators.confirmPassword(_passwordController.text),
                            onFieldSubmitted: (_) => _onSubmit(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Reset Password',
                      onPressed: isLoading ? null : _onSubmit,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResetSuccessView extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const _ResetSuccessView({required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Password reset!',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your password has been successfully reset.\nYou can now sign in with your new password.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Sign In',
            onPressed: onBackToLogin,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
