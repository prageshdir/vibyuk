import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/utils/validators/form_validators.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/auth/presentation/widgets/otp_input_field.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _otpSent = false;
  String _phone = '';
  String _otp = '';
  bool _hasOtpError = false;
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
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

  void _onSendOtp() {
    if (!_phoneFormKey.currentState!.validate()) return;
    _phone = _phoneController.text;
    context.read<AuthBloc>().add(SendPhoneOtpEvent(phone: _phone));
  }

  void _onVerifyOtp() {
    if (_otp.length < 6) {
      setState(() => _hasOtpError = true);
      return;
    }
    context.read<AuthBloc>().add(VerifyPhoneOtpEvent(phone: _phone, otp: _otp));
  }

  void _onResend() {
    if (_resendCountdown > 0) return;
    context.read<AuthBloc>().add(SendPhoneOtpEvent(phone: _phone));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case PhoneOtpSentState(:final phone):
            setState(() {
              _otpSent = true;
              _phone = phone;
              _hasOtpError = false;
            });
            _startResendTimer();
          case AuthenticatedState():
            context.go(RouteNames.home);
          case RoleSelectionRequiredState():
            context.go(RouteNames.roleSelection);
          case AuthErrorState(:final failure):
            setState(() => _hasOtpError = _otpSent);
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
            onPressed: () {
              if (_otpSent) {
                setState(() => _otpSent = false);
              } else {
                context.go(RouteNames.login);
              }
            },
          ),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoadingState;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _otpSent
                    ? _OtpVerificationStep(
                        key: const ValueKey('otp'),
                        phone: _phone,
                        isLoading: isLoading,
                        hasError: _hasOtpError,
                        resendCountdown: _resendCountdown,
                        onOtpCompleted: (otp) => setState(() {
                          _otp = otp;
                          _hasOtpError = false;
                        }),
                        onVerify: _onVerifyOtp,
                        onResend: _onResend,
                      )
                    : _PhoneEntryStep(
                        key: const ValueKey('phone'),
                        formKey: _phoneFormKey,
                        controller: _phoneController,
                        isLoading: isLoading,
                        onSend: _onSendOtp,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PhoneEntryStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const _PhoneEntryStep({
    super.key,
    required this.formKey,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: const Icon(Icons.phone_outlined, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Phone login',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your phone number and we\'ll send you a verification code.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 40),
          Form(
            key: formKey,
            child: AppTextField(
              controller: controller,
              label: 'Phone number',
              hint: '+1 234 567 8900',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.phone_outlined),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\s\(\)]'))],
              validator: (v) {
                final err = FormValidators.required(v, fieldName: 'Phone number');
                if (err != null) return err;
                return FormValidators.phone(v);
              },
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Send OTP',
            onPressed: isLoading ? null : onSend,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _OtpVerificationStep extends StatelessWidget {
  final String phone;
  final bool isLoading;
  final bool hasError;
  final int resendCountdown;
  final ValueChanged<String> onOtpCompleted;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpVerificationStep({
    super.key,
    required this.phone,
    required this.isLoading,
    required this.hasError,
    required this.resendCountdown,
    required this.onOtpCompleted,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: const Icon(Icons.sms_outlined, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Enter OTP',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              children: [
                const TextSpan(text: 'Code sent to '),
                TextSpan(
                  text: phone,
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
            onCompleted: onOtpCompleted,
            onChanged: onOtpCompleted,
            hasError: hasError,
          ),
          if (hasError) ...[
            const SizedBox(height: 8),
            Text(
              'Invalid code. Please try again.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Verify',
            onPressed: isLoading ? null : onVerify,
            isLoading: isLoading,
          ),
          const SizedBox(height: 24),
          Center(
            child: resendCountdown > 0
                ? Text(
                    'Resend code in ${resendCountdown}s',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : TextButton(
                    onPressed: isLoading ? null : onResend,
                    child: const Text('Resend code'),
                  ),
          ),
        ],
      ),
    );
  }
}
