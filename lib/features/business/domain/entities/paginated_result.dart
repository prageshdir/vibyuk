import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  bool get hasNextPage => currentPage < totalPages;
  bool get isFirstPage => currentPage == 1;
  bool get isEmpty => items.isEmpty;

  PaginatedResult<T> appendPage(PaginatedResult<T> next) => PaginatedResult<T>(
        items: [...items, ...next.items],
        currentPage: next.currentPage,
        totalPages: next.totalPages,
        totalItems: next.totalItems,
      );

  @override
  List<Object?> get props => [items, currentPage, totalPages, totalItems];
}
