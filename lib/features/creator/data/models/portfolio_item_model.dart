import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';

class PortfolioItemModel {
  const PortfolioItemModel({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.tags = const [],
    required this.sortOrder,
    required this.isFeatured,
    required this.createdAt,
  });

  final String id;
  final String creatorId;
  final String title;
  final String? description;
  final String mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final List<String> tags;
  final int sortOrder;
  final bool isFeatured;
  final DateTime createdAt;

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) =>
      PortfolioItemModel(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        mediaType: json['media_type'] as String? ?? 'image',
        mediaUrl: json['media_url'] as String,
        thumbnailUrl: json['thumbnail_url'] as String?,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        sortOrder: json['sort_order'] as int? ?? 0,
        isFeatured: json['is_featured'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  PortfolioItemEntity toEntity() => PortfolioItemEntity(
        id: id,
        creatorId: creatorId,
        title: title,
        description: description,
        mediaType: mediaType == 'video' ? MediaType.video : MediaType.image,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        tags: tags,
        sortOrder: sortOrder,
        isFeatured: isFeatured,
        createdAt: createdAt,
      );
}
