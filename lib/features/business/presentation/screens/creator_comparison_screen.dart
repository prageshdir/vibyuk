import 'package:flutter/material.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';

class CreatorComparisonScreen extends StatelessWidget {
  const CreatorComparisonScreen({super.key, required this.creators});
  final List<CreatorEntity> creators;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Creators',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: creators.isEmpty
          ? const Center(child: Text('No creators selected'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _CreatorHeaderRow(creators: creators),
                  const SizedBox(height: 20),
                  _CompareSection(
                    label: 'Rating',
                    values: creators
                        .map((c) =>
                            _CompareValue(
                              text: c.reviewsCount > 0
                                  ? c.rating.toStringAsFixed(1)
                                  : '—',
                              subtitle: '${c.reviewsCount} reviews',
                            ))
                        .toList(),
                  ),
                  _CompareSection(
                    label: 'Hourly Rate',
                    values: creators
                        .map((c) => _CompareValue(text: c.rateDisplay))
                        .toList(),
                  ),
                  _CompareSection(
                    label: 'Followers',
                    values: creators
                        .map((c) => _CompareValue(
                              text: _formatK(c.followersCount),
                            ))
                        .toList(),
                  ),
                  _CompareSection(
                    label: 'Bookings',
                    values: creators
                        .map((c) =>
                            _CompareValue(text: '${c.totalBookings}'))
                        .toList(),
                  ),
                  _CompareSection(
                    label: 'Location',
                    values: creators
                        .map((c) =>
                            _CompareValue(text: c.location ?? '—'))
                        .toList(),
                  ),
                  _CompareSection(
                    label: 'Verified',
                    values: creators
                        .map((c) => _CompareValue(
                              text: c.isVerified ? 'Yes' : 'No',
                              highlight: c.isVerified,
                            ))
                        .toList(),
                  ),
                  _CompareSection(
                    label: 'Availability',
                    values: creators
                        .map((c) => _CompareValue(
                              text: c.isAvailable ? 'Available' : 'Busy',
                              highlight: c.isAvailable,
                            ))
                        .toList(),
                  ),
                  _CompareCategoriesSection(creators: creators),
                  const SizedBox(height: 24),
                  Row(
                    children: creators.map((c) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilledButton(
                            onPressed: () {},
                            child: Text('Book ${c.displayName.split(' ').first}',
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatK(int n) => n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}M'
      : n >= 1000
          ? '${(n / 1000).toStringAsFixed(0)}K'
          : '$n';
}

class _CreatorHeaderRow extends StatelessWidget {
  const _CreatorHeaderRow({required this.creators});
  final List<CreatorEntity> creators;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 90),
        ...creators.map((c) => Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: c.avatarUrl != null
                        ? NetworkImage(c.avatarUrl!)
                        : null,
                    child: c.avatarUrl == null
                        ? Text(c.initials,
                            style: const TextStyle(fontWeight: FontWeight.w700))
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (c.isVerified)
                    const Icon(Icons.verified_rounded,
                        size: 13, color: Colors.blue),
                ],
              ),
            )),
      ],
    );
  }
}

class _CompareValue {
  const _CompareValue({required this.text, this.subtitle, this.highlight = false});
  final String text;
  final String? subtitle;
  final bool highlight;
}

class _CompareSection extends StatelessWidget {
  const _CompareSection({required this.label, required this.values});
  final String label;
  final List<_CompareValue> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...values.map((v) => Expanded(
                  child: Column(
                    children: [
                      Text(
                        v.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: v.highlight ? theme.colorScheme.primary : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (v.subtitle != null)
                        Text(
                          v.subtitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CompareCategoriesSection extends StatelessWidget {
  const _CompareCategoriesSection({required this.creators});
  final List<CreatorEntity> creators;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              'Niches',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...creators.map((c) => Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: c.categories.take(3).map((cat) {
                    return Chip(
                      label: Text(cat,
                          style: const TextStyle(fontSize: 10)),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              )),
        ],
      ),
    );
  }
}
