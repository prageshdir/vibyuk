import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';

class SocialLinksDisplay extends StatelessWidget {
  final SocialLinks links;

  const SocialLinksDisplay({super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (links.instagram != null)
          _SocialChip(
            label: '@${links.instagram}',
            icon: Icons.camera_alt_outlined,
            color: const Color(0xFFE4405F),
          ),
        if (links.twitter != null)
          _SocialChip(
            label: '@${links.twitter}',
            icon: Icons.alternate_email_rounded,
            color: const Color(0xFF1DA1F2),
          ),
        if (links.tiktok != null)
          _SocialChip(
            label: '@${links.tiktok}',
            icon: Icons.music_note_rounded,
            color: const Color(0xFF000000),
          ),
        if (links.youtube != null)
          _SocialChip(
            label: links.youtube!,
            icon: Icons.play_circle_outline_rounded,
            color: const Color(0xFFFF0000),
          ),
        if (links.linkedin != null)
          _SocialChip(
            label: links.linkedin!,
            icon: Icons.business_rounded,
            color: const Color(0xFF0077B5),
          ),
      ],
    );
  }
}

class _SocialChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SocialChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
