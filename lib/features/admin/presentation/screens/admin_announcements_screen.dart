import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

enum AnnouncementTarget {
  all,
  creators,
  businesses,
  premiumOnly;

  String get label => switch (this) {
        AnnouncementTarget.all => 'All Users',
        AnnouncementTarget.creators => 'Creators Only',
        AnnouncementTarget.businesses => 'Businesses Only',
        AnnouncementTarget.premiumOnly => 'Premium Subscribers',
      };

  String get apiValue => switch (this) {
        AnnouncementTarget.all => 'all',
        AnnouncementTarget.creators => 'creators',
        AnnouncementTarget.businesses => 'businesses',
        AnnouncementTarget.premiumOnly => 'premium',
      };
}

enum AnnouncementChannel {
  push,
  email,
  sms,
  inApp;

  String get label => switch (this) {
        AnnouncementChannel.push => 'Push Notification',
        AnnouncementChannel.email => 'Email',
        AnnouncementChannel.sms => 'SMS',
        AnnouncementChannel.inApp => 'In-App Banner',
      };

  IconData get icon => switch (this) {
        AnnouncementChannel.push => Icons.notifications_active_outlined,
        AnnouncementChannel.email => Icons.email_outlined,
        AnnouncementChannel.sms => Icons.sms_outlined,
        AnnouncementChannel.inApp => Icons.announcement_outlined,
      };
}

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _actionUrlController = TextEditingController();

  AnnouncementTarget _target = AnnouncementTarget.all;
  final Set<AnnouncementChannel> _channels = {AnnouncementChannel.push};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _actionUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: AppColors.electricViolet,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Send Announcement'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ComposeTab(
            formKey: _formKey,
            titleController: _titleController,
            bodyController: _bodyController,
            actionUrlController: _actionUrlController,
            target: _target,
            channels: _channels,
            isSending: _isSending,
            onTargetChanged: (t) => setState(() => _target = t),
            onChannelToggled: (ch) => setState(() {
              if (_channels.contains(ch)) {
                if (_channels.length > 1) _channels.remove(ch);
              } else {
                _channels.add(ch);
              }
            }),
            onSend: _sendAnnouncement,
          ),
          const _HistoryTab(),
        ],
      ),
    );
  }

  Future<void> _sendAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_channels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one channel')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Announcement?'),
        content: Text(
          'This will send "${_titleController.text}" to ${_target.label} via '
          '${_channels.map((c) => c.label).join(", ")}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSending = true);
    // In production, call the API. Here we simulate a delay.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSending = false);

    _formKey.currentState?.reset();
    _titleController.clear();
    _bodyController.clear();
    _actionUrlController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Announcement sent successfully'),
        backgroundColor: AppColors.success,
      ),
    );
    _tabController.animateTo(1);
  }
}

class _ComposeTab extends StatelessWidget {
  const _ComposeTab({
    required this.formKey,
    required this.titleController,
    required this.bodyController,
    required this.actionUrlController,
    required this.target,
    required this.channels,
    required this.isSending,
    required this.onTargetChanged,
    required this.onChannelToggled,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final TextEditingController actionUrlController;
  final AnnouncementTarget target;
  final Set<AnnouncementChannel> channels;
  final bool isSending;
  final ValueChanged<AnnouncementTarget> onTargetChanged;
  final ValueChanged<AnnouncementChannel> onChannelToggled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('Target Audience'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AnnouncementTarget.values
                  .map((t) => ChoiceChip(
                        label: Text(t.label),
                        selected: target == t,
                        onSelected: (_) => onTargetChanged(t),
                        selectedColor:
                            AppColors.electricViolet.withAlpha(30),
                        labelStyle: TextStyle(
                          color: target == t
                              ? AppColors.electricViolet
                              : null,
                          fontWeight: target == t
                              ? FontWeight.w600
                              : null,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Channels'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AnnouncementChannel.values
                  .map((ch) => FilterChip(
                        avatar: Icon(ch.icon, size: 16),
                        label: Text(ch.label),
                        selected: channels.contains(ch),
                        onSelected: (_) => onChannelToggled(ch),
                        selectedColor:
                            AppColors.electricViolet.withAlpha(30),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Message'),
            const SizedBox(height: 8),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. Platform maintenance scheduled',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              maxLength: 80,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Body *',
                hintText: 'Write your announcement message here...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Body is required' : null,
              maxLength: 500,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: actionUrlController,
              decoration: const InputDecoration(
                labelText: 'Action URL (optional)',
                hintText: 'e.g. /campaigns',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(isSending ? 'Sending...' : 'Send Announcement'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // In production, load from API. Show placeholder list.
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _mockHistory.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = _mockHistory[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.electricViolet.withAlpha(26),
            child: Icon(Icons.campaign_outlined,
                color: AppColors.electricViolet, size: 20),
          ),
          title: Text(item['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${item["target"]} · ${item["channels"]} · ${item["date"]}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Sent',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: AppColors.success)),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
    );
  }
}

final _mockHistory = [
  {
    'title': 'New AI Campaign Planner',
    'target': 'All Users',
    'channels': 'Push, Email',
    'date': '25 May 2026',
  },
  {
    'title': 'Weekend Booking Offer',
    'target': 'Businesses Only',
    'channels': 'Push',
    'date': '18 May 2026',
  },
  {
    'title': 'Creator Verification Update',
    'target': 'Creators Only',
    'channels': 'Email, In-App',
    'date': '12 May 2026',
  },
];
