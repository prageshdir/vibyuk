import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/utils/validators/form_validators.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/auth/presentation/widgets/auth_divider.dart';
import 'package:vibyuk/features/auth/presentation/widgets/auth_header.dart';
import 'package:vibyuk/features/auth/presentation/widgets/biometric_button.dart';
import 'package:vibyuk/features/auth/presentation/widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    // Check biometric availability through BLoC state
    // Show biometric button only if user has it enabled
    setState(() => _showBiometric = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          LoginWithEmailEvent(
            email: _emailController.text,
            password: _passwordController.text,
            rememberMe: _rememberMe,
          ),
        );
  }

  void _onGoogleLogin() {
    context.read<AuthBloc>().add(const LoginWithGoogleEvent());
  }

  void _onPhoneLogin() {
    context.go(RouteNames.phoneOtp);
  }

  void _onBiometricLogin() {
    context.read<AuthBloc>().add(const BiometricLoginEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthenticatedState():
            context.go(RouteNames.home);
          case RoleSelectionRequiredState():
            context.go(RouteNames.roleSelection);
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
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AuthHeader(
                            title: 'Welcome back',
                            subtitle: 'Sign in to continue your journey',
                          ),
                          const SizedBox(height: 40),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
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
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: '••••••••',
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  validator: (v) => FormValidators.required(v, fieldName: 'Password'),
                                  onFieldSubmitted: (_) => _onLogin(),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: isLoading
                                            ? null
                                            : (v) => setState(() => _rememberMe = v ?? false),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Remember me', style: theme.textTheme.bodyMedium),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => context.go(RouteNames.forgotPassword),
                                      child: const Text('Forgot password?'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                PrimaryButton(
                                  label: 'Sign In',
                                  onPressed: isLoading ? null : _onLogin,
                                  isLoading: isLoading,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_showBiometric) ...[
                            Center(child: BiometricButton(onPressed: _onBiometricLogin, isLoading: isLoading)),
                            const SizedBox(height: 24),
                          ],
                          const AuthDivider(),
                          const SizedBox(height: 24),
                          SocialAuthButton(
                            provider: SocialProvider.google,
                            onPressed: isLoading ? null : _onGoogleLogin,
                            isLoading: state is AuthLoadingState && state.message == null,
                          ),
                          const SizedBox(height: 12),
                          SocialAuthButton(
                            provider: SocialProvider.phone,
                            onPressed: isLoading ? null : _onPhoneLogin,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: theme.textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context.go(RouteNames.register),
                                child: const Text('Sign Up'),
                              ),
                            ],
                          ),
                        ],
                      ),
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
