import 'package:flutter/material.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/gallery_grid_widget.dart';

class DestinationGalleryScreen extends StatelessWidget {
  const DestinationGalleryScreen({
    super.key,
    required this.destination,
  });

  final TourismDestinationEntity destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${destination.name} Gallery',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${destination.galleryUrls.length} photos',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: destination.galleryUrls.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No gallery images available'),
                ],
              ),
            )
          : GalleryGridWidget(
              imageUrls: destination.galleryUrls,
              crossAxisCount: 3,
              spacing: 2,
              onImageTap: (index) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullscreenGalleryViewer(
                      imageUrls: destination.galleryUrls,
                      initialIndex: index,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
