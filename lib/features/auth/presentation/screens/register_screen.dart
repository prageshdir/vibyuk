import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/utils/validators/form_validators.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/auth/presentation/widgets/auth_divider.dart';
import 'package:vibyuk/features/auth/presentation/widgets/auth_header.dart';
import 'package:vibyuk/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:vibyuk/features/auth/presentation/widgets/social_auth_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _password = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          RegisterEvent(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case EmailVerificationRequiredState(:final email):
            context.go('${RouteNames.verifyEmail}?email=${Uri.encodeComponent(email)}');
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
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoadingState;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => context.go(RouteNames.login),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const AuthHeader(
                          title: 'Create account',
                          subtitle: 'Join the VIBYUK community today',
                          showLogo: false,
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _firstNameController,
                                      label: 'First name',
                                      hint: 'Alex',
                                      textInputAction: TextInputAction.next,
                                      validator: (v) => FormValidators.required(v, fieldName: 'First name'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _lastNameController,
                                      label: 'Last name',
                                      hint: 'Johnson',
                                      textInputAction: TextInputAction.next,
                                      validator: (v) => FormValidators.required(v, fieldName: 'Last name'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'you@example.com',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.email_outlined),
                                validator: FormValidators.email,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _phoneController,
                                label: 'Phone (optional)',
                                hint: '+1 234 567 8900',
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.phone_outlined),
                                validator: FormValidators.phone,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _passwordController,
                                label: 'Password',
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
                                controller: _confirmPasswordController,
                                label: 'Confirm password',
                                hint: '••••••••',
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                validator: FormValidators.confirmPassword(_passwordController.text),
                                onFieldSubmitted: (_) => _onRegister(),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Create Account',
                                onPressed: isLoading ? null : _onRegister,
                                isLoading: isLoading,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AuthDivider(),
                        const SizedBox(height: 24),
                        SocialAuthButton(
                          provider: SocialProvider.google,
                          onPressed: isLoading
                              ? null
                              : () => context.read<AuthBloc>().add(const LoginWithGoogleEvent()),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: isLoading ? null : () => context.go(RouteNames.login),
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
