import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/utils/validators/form_validators.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:vibyuk/features/profile/presentation/widgets/settings_tile.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is AccountDeletedState) {
          context.read<AuthBloc>().add(const LogoutEvent());
          context.go(RouteNames.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account Settings'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            SettingsSection(
              title: 'Data & Privacy',
              children: [
                SettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Download My Data',
                  subtitle: 'Request a copy of your account data',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.visibility_off_outlined,
                  title: 'Privacy Settings',
                  subtitle: 'Control who can see your profile',
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),
            SettingsSection(
              title: 'Danger Zone',
              children: [
                SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and data',
                  isDestructive: true,
                  showDivider: false,
                  onTap: () => _showDeleteDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: _DeleteAccountSheet(),
      ),
    );
  }
}

class _DeleteAccountSheet extends StatefulWidget {
  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onDelete() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
          DeleteAccountEvent(password: _passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is AccountDeletedState) {
          Navigator.of(context).pop();
        } else if (state is ProfileErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isLoading = state is AccountDeletingState;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.delete_forever_outlined,
                    size: 28,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete account?',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action is permanent and cannot be undone. All your data, bookings, and profile will be deleted.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  value: _confirmed,
                  onChanged: (v) => setState(() => _confirmed = v ?? false),
                  title: Text(
                    'I understand this action is permanent',
                    style: theme.textTheme.bodyMedium,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                if (_confirmed) ...[
                  Form(
                    key: _formKey,
                    child: AppTextField(
                      controller: _passwordController,
                      label: 'Confirm your password',
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      validator: (v) => FormValidators.required(v, fieldName: 'Password'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Delete My Account',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
