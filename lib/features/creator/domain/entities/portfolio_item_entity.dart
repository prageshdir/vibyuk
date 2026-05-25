import 'package:equatable/equatable.dart';

enum MediaType { image, video }

class PortfolioItemEntity extends Equatable {
  final String id;
  final String creatorId;
  final String title;
  final String? description;
  final MediaType mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final List<String> tags;
  final int sortOrder;
  final bool isFeatured;
  final DateTime createdAt;

  const PortfolioItemEntity({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.tags,
    required this.sortOrder,
    required this.isFeatured,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        creatorId,
        title,
        description,
        mediaType,
        mediaUrl,
        thumbnailUrl,
        tags,
        sortOrder,
        isFeatured,
        createdAt,
      ];
}
