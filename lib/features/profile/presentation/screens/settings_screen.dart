import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/theme/theme_bloc.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:vibyuk/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:vibyuk/features/profile/presentation/screens/notification_settings_screen.dart';
import 'package:vibyuk/features/profile/presentation/widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is AccountDeletedState) {
            context.read<AuthBloc>().add(const LogoutEvent());
          }
        },
        child: ListView(
          children: [
            SettingsSection(
              title: 'Account',
              children: [
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () => context.go(RouteNames.editProfile),
                ),
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProfileBloc>(),
                        child: const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.security_rounded,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security',
                  onTap: () => context.push(RouteNames.twoFactorSetup),
                ),
                SettingsTile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Account Settings',
                  subtitle: 'Privacy, data, and account management',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProfileBloc>(),
                        child: const AccountSettingsScreen(),
                      ),
                    ),
                  ),
                  showDivider: false,
                ),
              ],
            ),
            SettingsSection(
              title: 'Preferences',
              children: [
                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProfileBloc>(),
                        child: const NotificationSettingsScreen(),
                      ),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  title: isDark ? 'Light Mode' : 'Dark Mode',
                  subtitle: 'Switch app appearance',
                  onTap: () => context.read<ThemeBloc>().add(ThemeToggled()),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => context.read<ThemeBloc>().add(ThemeToggled()),
                    activeColor: AppColors.primary,
                  ),
                  showDivider: false,
                ),
              ],
            ),
            SettingsSection(
              title: 'Support',
              children: [
                SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & FAQ',
                  subtitle: 'Get answers to common questions',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Contact Support',
                  subtitle: 'Reach our team',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate the App',
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),
            SettingsSection(
              title: 'Legal',
              children: [
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),
            SettingsSection(
              title: 'Session',
              children: [
                SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  isDestructive: true,
                  showDivider: false,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'VIBYUK v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
              context.go(RouteNames.login);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
