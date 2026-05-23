import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/auth/presentation/widgets/otp_input_field.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String _otp = '';
  bool _hasError = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  void _onOtpCompleted(String otp) {
    setState(() {
      _otp = otp;
      _hasError = false;
    });
  }

  void _onVerify() {
    if (_otp.length < 6) {
      setState(() => _hasError = true);
      return;
    }
    context.read<AuthBloc>().add(
          VerifyEmailOtpEvent(email: widget.email, otp: _otp),
        );
  }

  void _onResend() {
    if (_resendCountdown > 0) return;
    context.read<AuthBloc>().add(ResendEmailOtpEvent(email: widget.email));
    _startResendTimer();
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
          case EmailOtpResentState():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP resent successfully.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          case AuthErrorState(:final failure):
            setState(() => _hasError = true);
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
                        Icons.mark_email_read_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verify your email',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: 'We sent a 6-digit code to\n'),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    OtpInputField(
                      onCompleted: _onOtpCompleted,
                      onChanged: (v) => setState(() {
                        _otp = v;
                        _hasError = false;
                      }),
                      hasError: _hasError,
                    ),
                    if (_hasError) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Invalid or expired code. Please try again.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Verify Email',
                      onPressed: isLoading || _otp.length < 6 ? null : _onVerify,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: _resendCountdown > 0
                          ? Text.rich(
                              TextSpan(
                                text: "Didn't receive the code? ",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Resend in ${_resendCountdown}s',
                                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            )
                          : TextButton(
                              onPressed: isLoading ? null : _onResend,
                              child: const Text('Resend code'),
                            ),
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
