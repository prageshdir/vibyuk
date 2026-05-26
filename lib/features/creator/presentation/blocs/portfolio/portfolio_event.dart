part of 'portfolio_bloc.dart';

sealed class PortfolioEvent extends Equatable {
  const PortfolioEvent();
}

class LoadPortfolioEvent extends PortfolioEvent {
  const LoadPortfolioEvent();
  @override
  List<Object?> get props => [];
}

class LoadMorePortfolioEvent extends PortfolioEvent {
  const LoadMorePortfolioEvent();
  @override
  List<Object?> get props => [];
}

class AddPortfolioItemEvent extends PortfolioEvent {
  const AddPortfolioItemEvent({
    required this.title,
    this.description,
    required this.mediaType,
    required this.filePath,
    required this.tags,
    this.isFeatured = false,
  });
  final String title;
  final String? description;
  final MediaType mediaType;
  final String filePath;
  final List<String> tags;
  final bool isFeatured;
  @override
  List<Object?> get props => [title, description, mediaType, filePath, tags, isFeatured];
}

class UpdatePortfolioItemEvent extends PortfolioEvent {
  const UpdatePortfolioItemEvent({
    required this.itemId,
    required this.title,
    this.description,
    required this.tags,
    required this.isFeatured,
  });
  final String itemId;
  final String title;
  final String? description;
  final List<String> tags;
  final bool isFeatured;
  @override
  List<Object?> get props => [itemId, title, description, tags, isFeatured];
}

class DeletePortfolioItemEvent extends PortfolioEvent {
  const DeletePortfolioItemEvent({required this.itemId});
  final String itemId;
  @override
  List<Object?> get props => [itemId];
}

class ReorderPortfolioEvent extends PortfolioEvent {
  const ReorderPortfolioEvent({required this.orderedIds});
  final List<String> orderedIds;
  @override
  List<Object?> get props => [orderedIds];
}
