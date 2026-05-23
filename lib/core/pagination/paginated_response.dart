import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_response.freezed.dart';

@freezed
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const PaginatedResponse._();

  const factory PaginatedResponse({
    required List<T> items,
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required int perPage,
  }) = _PaginatedResponse<T>;

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPrevPage => currentPage > 1;
  bool get isEmpty => items.isEmpty;
  bool get isLastPage => !hasNextPage;

  PaginatedResponse<T> appendPage(PaginatedResponse<T> nextPage) {
    return PaginatedResponse<T>(
      items: [...items, ...nextPage.items],
      currentPage: nextPage.currentPage,
      totalPages: nextPage.totalPages,
      totalItems: nextPage.totalItems,
      perPage: nextPage.perPage,
    );
  }

  static PaginatedResponse<T> fromApiResponse<T>({
    required List<T> items,
    required Map<String, dynamic> meta,
  }) {
    return PaginatedResponse<T>(
      items: items,
      currentPage: (meta['current_page'] as int?) ?? 1,
      totalPages: (meta['last_page'] as int?) ?? 1,
      totalItems: (meta['total'] as int?) ?? items.length,
      perPage: (meta['per_page'] as int?) ?? 20,
    );
  }
}
