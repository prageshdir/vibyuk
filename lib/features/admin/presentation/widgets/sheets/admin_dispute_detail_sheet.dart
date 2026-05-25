import 'package:flutter/material.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_status_badge.dart';

class AdminDisputeDetailSheet extends StatefulWidget {
  final AdminDispute dispute;
  final void Function(DisputeResolution resolution, String note, double? refundAmount) onResolve;
  final void Function(String content) onSendMessage;

  const AdminDisputeDetailSheet({
    super.key,
    required this.dispute,
    required this.onResolve,
    required this.onSendMessage,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminDispute dispute,
    required void Function(DisputeResolution, String, double?) onResolve,
    required void Function(String) onSendMessage,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminDisputeDetailSheet(
        dispute: dispute,
        onResolve: onResolve,
        onSendMessage: onSendMessage,
      ),
    );
  }

  @override
  State<AdminDisputeDetailSheet> createState() =>
      _AdminDisputeDetailSheetState();
}

class _AdminDisputeDetailSheetState extends State<AdminDisputeDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  DisputeResolution? _resolution;
  final _noteCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _refundCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _noteCtrl.dispose();
    _msgCtrl.dispose();
    _refundCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return Container(
      height: mq.size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.dispute.subject,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _statusBadge(widget.dispute.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '#${widget.dispute.id.substring(0, 8).toUpperCase()} · ${widget.dispute.daysSinceOpened}d open',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Messages'),
              Tab(text: 'Resolve'),
            ],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _DetailsTab(dispute: widget.dispute),
                _MessagesTab(
                  dispute: widget.dispute,
                  msgCtrl: _msgCtrl,
                  onSend: () {
                    final c = _msgCtrl.text.trim();
                    if (c.isEmpty) return;
                    widget.onSendMessage(c);
                    _msgCtrl.clear();
                  },
                ),
                _ResolveTab(
                  dispute: widget.dispute,
                  resolution: _resolution,
                  noteCtrl: _noteCtrl,
                  refundCtrl: _refundCtrl,
                  onResolutionChanged: (r) =>
                      setState(() => _resolution = r),
                  onSubmit: () {
                    if (_resolution == null) return;
                    widget.onResolve(
                      _resolution!,
                      _noteCtrl.text.trim(),
                      _refundCtrl.text.isEmpty
                          ? null
                          : double.tryParse(_refundCtrl.text),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(DisputeStatus status) => switch (status) {
        DisputeStatus.open => AdminStatusBadge.warning('Open'),
        DisputeStatus.inReview => AdminStatusBadge.info('In Review'),
        DisputeStatus.pendingInfo => AdminStatusBadge.neutral('Pending Info'),
        DisputeStatus.resolved => AdminStatusBadge.success('Resolved'),
        DisputeStatus.closed => AdminStatusBadge.neutral('Closed'),
        DisputeStatus.escalated => AdminStatusBadge.danger('Escalated'),
      };
}

class _DetailsTab extends StatelessWidget {
  final AdminDispute dispute;
  const _DetailsTab({required this.dispute});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section(title: 'Description', child: Text(dispute.description)),
        const SizedBox(height: 16),
        _Section(
          title: 'Parties',
          child: Column(
            children: [
              _PartyRow(
                label: 'Complainant',
                name: dispute.complainant.displayName,
                role: dispute.complainant.role,
              ),
              const Divider(height: 16),
              _PartyRow(
                label: 'Respondent',
                name: dispute.respondent.displayName,
                role: dispute.respondent.role,
              ),
            ],
          ),
        ),
        if (dispute.evidence.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            title: 'Evidence (${dispute.evidence.length})',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dispute.evidence
                  .map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.attach_file_rounded, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              e.type,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _MessagesTab extends StatelessWidget {
  final AdminDispute dispute;
  final TextEditingController msgCtrl;
  final VoidCallback onSend;

  const _MessagesTab({
    required this.dispute,
    required this.msgCtrl,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: dispute.messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dispute.messages.length,
                  itemBuilder: (_, i) {
                    final msg = dispute.messages[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isInternal
                            ? const Color(0xFF7B2FFF).withOpacity(0.06)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: msg.isInternal
                            ? Border.all(
                                color: const Color(0xFF7B2FFF).withOpacity(0.15),
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                msg.senderName,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (msg.isInternal)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7B2FFF)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'internal',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF7B2FFF),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(msg.content, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: msgCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Write a message...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2FFF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResolveTab extends StatelessWidget {
  final AdminDispute dispute;
  final DisputeResolution? resolution;
  final TextEditingController noteCtrl;
  final TextEditingController refundCtrl;
  final ValueChanged<DisputeResolution> onResolutionChanged;
  final VoidCallback onSubmit;

  const _ResolveTab({
    required this.dispute,
    required this.resolution,
    required this.noteCtrl,
    required this.refundCtrl,
    required this.onResolutionChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Resolution',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        ...DisputeResolution.values.map((r) {
          final sel = resolution == r;
          final (label, color) = _resolutionMeta(r);
          return GestureDetector(
            onTap: () => onResolutionChanged(r),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sel ? color.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? color : Theme.of(context).colorScheme.outline.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: sel ? color : Colors.grey, width: 2),
                      color: sel ? color : Colors.transparent,
                    ),
                    child: sel
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: sel ? color : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        if (resolution == DisputeResolution.refundComplainant ||
            resolution == DisputeResolution.partialRefund) ...[
          TextField(
            controller: refundCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Refund Amount',
              prefixText: '\$',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            labelText: 'Resolution Note',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Submit Resolution',
          onPressed: resolution != null ? onSubmit : null,
        ),
      ],
    );
  }

  (String, Color) _resolutionMeta(DisputeResolution r) => switch (r) {
        DisputeResolution.refundComplainant =>
          ('Full Refund to Complainant', const Color(0xFF00D9C0)),
        DisputeResolution.refundRespondent =>
          ('Refund to Respondent', const Color(0xFF7B2FFF)),
        DisputeResolution.partialRefund =>
          ('Partial Refund', const Color(0xFFFFB020)),
        DisputeResolution.noRefund => ('No Refund', Colors.grey),
        DisputeResolution.dismissed => ('Dismiss Dispute', Colors.grey),
        DisputeResolution.escalated =>
          ('Escalate to Higher Level', const Color(0xFFFF5C6B)),
      };
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _PartyRow extends StatelessWidget {
  final String label;
  final String name;
  final String role;
  const _PartyRow({required this.label, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 6),
        Text(
          '($role)',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
        ),
      ],
    );
  }
}
