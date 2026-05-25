import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class GalleryGridWidget extends StatelessWidget {
  const GalleryGridWidget({
    super.key,
    required this.imageUrls,
    this.onImageTap,
    this.crossAxisCount = 3,
    this.spacing = 3,
    this.maxItems,
  });

  final List<String> imageUrls;
  final void Function(int index)? onImageTap;
  final int crossAxisCount;
  final double spacing;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final displayUrls =
        maxItems != null ? imageUrls.take(maxItems!).toList() : imageUrls;
    final hasMore =
        maxItems != null && imageUrls.length > maxItems!;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: displayUrls.length,
      itemBuilder: (context, index) {
        final isLast = hasMore && index == displayUrls.length - 1;
        return GestureDetector(
          onTap: () => onImageTap?.call(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: displayUrls[index],
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.shimmerBase),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.outline),
                ),
              ),
              if (isLast)
                DecoratedBox(
                  decoration:
                      BoxDecoration(color: Colors.black.withValues(alpha: 0.55)),
                  child: Center(
                    child: Text(
                      '+${imageUrls.length - maxItems! + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class FullscreenGalleryViewer extends StatefulWidget {
  const FullscreenGalleryViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<FullscreenGalleryViewer> createState() =>
      _FullscreenGalleryViewerState();
}

class _FullscreenGalleryViewerState extends State<FullscreenGalleryViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                      child:
                          CircularProgressIndicator(color: Colors.white38)),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.white38, size: 64),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black38,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
