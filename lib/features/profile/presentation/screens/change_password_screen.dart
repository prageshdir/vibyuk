import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/utils/validators/form_validators.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:vibyuk/features/profile/presentation/bloc/profile_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String _newPassword = '';

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
          ChangePasswordEvent(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
            newPasswordConfirmation: _confirmController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        switch (state) {
          case PasswordChangedState():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          case ProfileErrorState(:final failure):
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
          title: const Text('Change Password'),
          centerTitle: true,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileLoadingState;

            return SingleChildScrollView(
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
                      Icons.lock_outline_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Update password',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your new password must be at least 8 characters and contain an uppercase letter and a number.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _currentController,
                          label: 'Current password',
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          validator: (v) => FormValidators.required(v, fieldName: 'Current password'),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _newController,
                          label: 'New password',
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          validator: FormValidators.password,
                          onChanged: (v) => setState(() => _newPassword = v),
                        ),
                        PasswordStrengthIndicator(password: _newPassword),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmController,
                          label: 'Confirm new password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          validator: FormValidators.confirmPassword(_newController.text),
                          onFieldSubmitted: (_) => _onSubmit(),
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          label: 'Change Password',
                          onPressed: isLoading ? null : _onSubmit,
                          isLoading: isLoading,
                        ),
                      ],
                    ),
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
