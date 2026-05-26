import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class KycUploadTile extends StatelessWidget {
  const KycUploadTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    this.filePath,
    this.previewUrl,
    required this.onTap,
    this.isRequired = true,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final String? filePath;
  final String? previewUrl;
  final VoidCallback onTap;
  final bool isRequired;

  bool get _hasFile => filePath != null || previewUrl != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _hasFile
                ? Colors.green
                : theme.colorScheme.outlineVariant,
            width: _hasFile ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _hasFile
              ? Colors.green.withValues(alpha: 0.05)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            // Preview or icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: _hasFile && previewUrl != null
                    ? Image.network(previewUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PlaceholderIcon(icon: icon))
                    : _hasFile && filePath != null
                        ? Container(
                            color: Colors.green.withValues(alpha: 0.1),
                            child: const Icon(Icons.check_circle_outline_rounded,
                                color: Colors.green, size: 30),
                          )
                        : _PlaceholderIcon(icon: icon),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        Text('*',
                            style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hasFile ? 'Uploaded ✓' : subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _hasFile
                          ? Colors.green
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _hasFile
                  ? Icons.check_circle_rounded
                  : Icons.upload_file_outlined,
              color: _hasFile ? Colors.green : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(icon, size: 28, color: Colors.grey),
    );
  }
}
