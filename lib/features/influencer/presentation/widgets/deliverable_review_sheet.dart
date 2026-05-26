import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';
import 'package:vibyuk/features/influencer/presentation/blocs/influencer_campaign/influencer_campaign_bloc.dart';

class DeliverableReviewSheet extends StatefulWidget {
  const DeliverableReviewSheet({super.key, required this.deliverable});
  final ContentDeliverableEntity deliverable;

  @override
  State<DeliverableReviewSheet> createState() => _DeliverableReviewSheetState();
}

class _DeliverableReviewSheetState extends State<DeliverableReviewSheet> {
  final _revisionController = TextEditingController();
  final _postUrlController = TextEditingController();
  bool _showRevisionField = false;
  bool _showPublishField = false;

  @override
  void dispose() {
    _revisionController.dispose();
    _postUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.deliverable;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          Text('Review Deliverable',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${d.influencerName} · ${d.type.label}',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          if (d.submittedContentUrl != null) ...[
            _ContentLink(url: d.submittedContentUrl!, label: 'Submitted content'),
            const SizedBox(height: 16),
          ],
          if (!_showRevisionField && !_showPublishField) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _showRevisionField = true),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Request Revision'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _approve(context),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
            if (d.status == DeliverableStatus.approved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () =>
                      setState(() => _showPublishField = true),
                  child: const Text('Mark as Published'),
                ),
              ),
            ],
          ],
          if (_showRevisionField) ...[
            TextField(
              controller: _revisionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Revision notes',
                hintText: 'Describe what changes are needed...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      setState(() => _showRevisionField = false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _requestRevision(context),
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
          if (_showPublishField) ...[
            TextField(
              controller: _postUrlController,
              decoration: const InputDecoration(
                labelText: 'Published post URL',
                hintText: 'https://instagram.com/p/...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      setState(() => _showPublishField = false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _markPublished(context),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _approve(BuildContext context) {
    context.read<InfluencerCampaignBloc>().add(ApproveDeliverableEvent(
      deliverableId: widget.deliverable.id,
      campaignId: widget.deliverable.campaignId,
    ));
    Navigator.of(context).pop();
  }

  void _requestRevision(BuildContext context) {
    final note = _revisionController.text.trim();
    if (note.isEmpty) return;
    context.read<InfluencerCampaignBloc>().add(RequestRevisionEvent(
      deliverableId: widget.deliverable.id,
      campaignId: widget.deliverable.campaignId,
      note: note,
    ));
    Navigator.of(context).pop();
  }

  void _markPublished(BuildContext context) {
    final url = _postUrlController.text.trim();
    if (url.isEmpty) return;
    context.read<InfluencerCampaignBloc>().add(MarkDeliverablePublishedEvent(
      deliverableId: widget.deliverable.id,
      campaignId: widget.deliverable.campaignId,
      postUrl: url,
    ));
    Navigator.of(context).pop();
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ContentLink extends StatelessWidget {
  const _ContentLink({required this.url, required this.label});
  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded,
              size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                Text(url,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
