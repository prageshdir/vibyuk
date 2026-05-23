import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/profile/domain/entities/notification_settings_entity.dart';
import 'package:vibyuk/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:vibyuk/features/profile/presentation/widgets/settings_tile.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  NotificationSettingsEntity? _settings;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadNotificationSettingsEvent());
  }

  void _toggle(NotificationSettingsEntity updated) {
    setState(() => _settings = updated);
    context.read<ProfileBloc>().add(
          UpdateNotificationSettingsEvent(settings: updated),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        switch (state) {
          case NotificationSettingsLoadedState(:final settings):
            setState(() => _settings = settings);
          case NotificationSettingsUpdatedState(:final settings):
            setState(() => _settings = settings);
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
          title: const Text('Notifications'),
          centerTitle: true,
        ),
        body: _settings == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  SettingsSection(
                    title: 'General',
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Push Notifications',
                        subtitle: 'Receive push notifications on this device',
                        trailing: Switch(
                          value: _settings!.pushEnabled,
                          onChanged: (v) => _toggle(_settings!.copyWith(pushEnabled: v)),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Email Notifications',
                        subtitle: 'Receive notifications by email',
                        trailing: Switch(
                          value: _settings!.emailEnabled,
                          onChanged: (v) => _toggle(_settings!.copyWith(emailEnabled: v)),
                          activeColor: AppColors.primary,
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Activity',
                    children: [
                      SettingsTile(
                        icon: Icons.calendar_month_outlined,
                        title: 'Booking Updates',
                        subtitle: 'Confirmations, cancellations, reminders',
                        trailing: Switch(
                          value: _settings!.bookingNotifications,
                          onChanged: (v) => _toggle(_settings!.copyWith(bookingNotifications: v)),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Messages',
                        subtitle: 'New messages and replies',
                        trailing: Switch(
                          value: _settings!.messageNotifications,
                          onChanged: (v) => _toggle(_settings!.copyWith(messageNotifications: v)),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.star_outline_rounded,
                        title: 'Reviews',
                        subtitle: 'New reviews on your profile',
                        trailing: Switch(
                          value: _settings!.reviewNotifications,
                          onChanged: (v) => _toggle(_settings!.copyWith(reviewNotifications: v)),
                          activeColor: AppColors.primary,
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Other',
                    children: [
                      SettingsTile(
                        icon: Icons.campaign_outlined,
                        title: 'Marketing & Promotions',
                        subtitle: 'Special offers and platform news',
                        trailing: Switch(
                          value: _settings!.marketingNotifications,
                          onChanged: (v) =>
                              _toggle(_settings!.copyWith(marketingNotifications: v)),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.security_outlined,
                        title: 'Security Alerts',
                        subtitle: 'Sign-in activity and account changes',
                        trailing: Switch(
                          value: _settings!.securityNotifications,
                          onChanged: (v) =>
                              _toggle(_settings!.copyWith(securityNotifications: v)),
                          activeColor: AppColors.primary,
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }
}
