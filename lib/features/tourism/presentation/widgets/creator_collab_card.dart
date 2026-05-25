import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';

class CreatorCollabCard extends StatelessWidget {
  const CreatorCollabCard({
    super.key,
    required this.collaboration,
    this.onTap,
  });

  final CreatorCollaborationEntity collaboration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo(context)),
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryContainer,
          backgroundImage: collaboration.creatorImageUrl != null
              ? CachedNetworkImageProvider(collaboration.creatorImageUrl!)
              : null,
          child: collaboration.creatorImageUrl == null
              ? Text(
                  collaboration.creatorName.isNotEmpty
                      ? collaboration.creatorName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                )
              : null,
        ),
        if (collaboration.isActive)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          collaboration.creatorName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _MiniStat(
              icon: Icons.visibility_outlined,
              value: collaboration.formattedReach,
            ),
            const SizedBox(width: 10),
            _MiniStat(
              icon: Icons.favorite_outline,
              value:
                  '${collaboration.engagementRate.toStringAsFixed(1)}%',
            ),
          ],
        ),
        if (collaboration.contentUrls.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildContentPreview(),
        ],
      ],
    );
  }

  Widget _buildContentPreview() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: collaboration.contentUrls.length.clamp(0, 5),
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: collaboration.contentUrls[index],
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.shimmerBase, width: 36),
              errorWidget: (_, __, ___) => Container(
                width: 36,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.image_outlined,
                    size: 16, color: AppColors.outline),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (label, color) = switch (collaboration.status) {
      CollaborationStatus.active => ('Active', AppColors.success),
      CollaborationStatus.pending => ('Pending', AppColors.warning),
      CollaborationStatus.completed => ('Done', AppColors.textSecondary),
      CollaborationStatus.cancelled => ('Cancelled', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
