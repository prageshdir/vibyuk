import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/error/error_view.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_preferences.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_preferences/notification_preferences_bloc.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<NotificationPreferencesBloc>()
        .add(const NotificationPreferencesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        centerTitle: false,
        actions: [
          BlocBuilder<NotificationPreferencesBloc,
              NotificationPreferencesState>(
            builder: (context, state) {
              final isSaving = state is NotificationPreferencesSaving;
              return isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationPreferencesBloc,
          NotificationPreferencesState>(
        listener: (context, state) {
          if (state is NotificationPreferencesSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preferences saved')),
            );
          } else if (state is NotificationPreferencesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            NotificationPreferencesInitial() ||
            NotificationPreferencesLoading() =>
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            NotificationPreferencesLoaded(preferences: final prefs) ||
            NotificationPreferencesSaving(preferences: final prefs) ||
            NotificationPreferencesSaved(preferences: final prefs) =>
              _PreferencesForm(preferences: prefs),
            NotificationPreferencesError(failure: final failure) => ErrorView(
                message: failure.message,
                onRetry: () => context
                    .read<NotificationPreferencesBloc>()
                    .add(const NotificationPreferencesLoadRequested()),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _PreferencesForm extends StatelessWidget {
  final NotificationPreferences preferences;

  const _PreferencesForm({required this.preferences});

  void _update(BuildContext context, NotificationPreferences updated) {
    context
        .read<NotificationPreferencesBloc>()
        .add(NotificationPreferencesUpdateRequested(updated));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SectionHeader(title: 'Channels'),
        _PreferenceTile(
          title: 'Push Notifications',
          subtitle: 'Receive alerts on your device',
          icon: Icons.notifications_active_outlined,
          value: preferences.pushEnabled,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(pushEnabled: v),
          ),
        ),
        _PreferenceTile(
          title: 'Email Notifications',
          subtitle: 'Receive a daily digest via email',
          icon: Icons.email_outlined,
          value: preferences.emailEnabled,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(emailEnabled: v),
          ),
        ),
        const Divider(height: 1),
        _SectionHeader(title: 'Alert Types'),
        _PreferenceTile(
          title: 'Booking Alerts',
          subtitle: 'Requests, confirmations and cancellations',
          icon: Icons.calendar_month_outlined,
          iconColor: AppColors.primary,
          value: preferences.bookingAlerts,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(bookingAlerts: v),
          ),
        ),
        _PreferenceTile(
          title: 'Chat Alerts',
          subtitle: 'New messages from creators and clients',
          icon: Icons.chat_bubble_outline,
          iconColor: AppColors.tertiary,
          value: preferences.chatAlerts,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(chatAlerts: v),
          ),
        ),
        _PreferenceTile(
          title: 'Payment Alerts',
          subtitle: 'Payments received, failed or refunded',
          icon: Icons.payments_outlined,
          iconColor: AppColors.success,
          value: preferences.paymentAlerts,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(paymentAlerts: v),
          ),
        ),
        _PreferenceTile(
          title: 'Campaign Alerts',
          subtitle: 'Campaign status updates and milestones',
          icon: Icons.campaign_outlined,
          iconColor: AppColors.warning,
          value: preferences.campaignAlerts,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(campaignAlerts: v),
          ),
        ),
        _PreferenceTile(
          title: 'Review Alerts',
          subtitle: 'New reviews on your profile',
          icon: Icons.star_outline,
          iconColor: AppColors.secondary,
          value: preferences.reviewAlerts,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(reviewAlerts: v),
          ),
        ),
        _PreferenceTile(
          title: 'Event Alerts',
          subtitle: 'Event reminders and updates',
          icon: Icons.event_outlined,
          iconColor: AppColors.primaryLight,
          value: preferences.eventAlerts,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(eventAlerts: v),
          ),
        ),
        _PreferenceTile(
          title: 'General Alerts',
          subtitle: 'System updates and announcements',
          icon: Icons.info_outline,
          value: preferences.generalAlerts,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(generalAlerts: v),
          ),
        ),
        const Divider(height: 1),
        _SectionHeader(title: 'Do Not Disturb'),
        _PreferenceTile(
          title: 'Do Not Disturb',
          subtitle: preferences.doNotDisturb
              ? 'Notifications are silenced'
              : 'All notifications active',
          icon: Icons.do_not_disturb_on_outlined,
          value: preferences.doNotDisturb,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(doNotDisturb: v),
          ),
        ),
        if (preferences.doNotDisturb) ...[
          _DndTimePicker(
            label: 'Start time',
            time: preferences.dndStartTime ?? '22:00',
            onChanged: (t) => _update(
              context,
              preferences.copyWith(dndStartTime: t),
            ),
          ),
          _DndTimePicker(
            label: 'End time',
            time: preferences.dndEndTime ?? '07:00',
            onChanged: (t) => _update(
              context,
              preferences.copyWith(dndEndTime: t),
            ),
          ),
        ],
        const Divider(height: 1),
        _SectionHeader(title: 'Sound & Vibration'),
        _PreferenceTile(
          title: 'Vibration',
          subtitle: 'Vibrate on new notifications',
          icon: Icons.vibration,
          value: preferences.vibrationEnabled,
          onChanged: (v) => _update(
            context,
            preferences.copyWith(vibrationEnabled: v),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppColors.textSecondary,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _DndTimePicker extends StatelessWidget {
  final String label;
  final String time;
  final ValueChanged<String> onChanged;

  const _DndTimePicker({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      trailing: GestureDetector(
        onTap: () async {
          final parts = time.split(':');
          final initial = TimeOfDay(
            hour: int.tryParse(parts.first) ?? 22,
            minute: int.tryParse(parts.last) ?? 0,
          );
          final picked = await showTimePicker(
            context: context,
            initialTime: initial,
          );
          if (picked != null) {
            final formatted =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
            onChanged(formatted);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
