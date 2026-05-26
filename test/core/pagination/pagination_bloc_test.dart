import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/pagination_bloc.dart';
import 'package:vibyuk/core/pagination/pagination_event.dart';
import 'package:vibyuk/core/pagination/pagination_state.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';

// ── Fake concrete BLoC ────────────────────────────────────────────────────

class _FakeItem {
  const _FakeItem(this.id);
  final int id;
}

class _FakePaginationBloc extends PaginationBloc<_FakeItem> {
  _FakePaginationBloc({required this.pageSupplier});

  final Future<Either<Failure, PaginatedResponse<_FakeItem>>> Function(
      int page) pageSupplier;

  @override
  Future<Either<Failure, PaginatedResponse<_FakeItem>>> fetchPage(
      int page) async {
    return pageSupplier(page);
  }
}

PaginatedResponse<_FakeItem> _page({
  required int page,
  required int total,
  int pageSize = 20,
  List<_FakeItem>? items,
}) {
  final data =
      items ?? List.generate(pageSize, (i) => _FakeItem(i + (page - 1) * pageSize));
  return PaginatedResponse(
    data: data,
    currentPage: page,
    totalPages: (total / pageSize).ceil(),
    totalItems: total,
    perPage: pageSize,
  );
}

void main() {
  group('PaginationBloc', () {
    test('initial state is PaginationInitial', () {
      final bloc = _FakePaginationBloc(
        pageSupplier: (_) async => Right(_page(page: 1, total: 40)),
      );
      expect(bloc.state, isA<PaginationInitial>());
      bloc.close();
    });

    blocTest<_FakePaginationBloc, PaginationState<_FakeItem>>(
      'FetchFirstPage emits Loading then Loaded with 20 items',
      build: () => _FakePaginationBloc(
        pageSupplier: (_) async => Right(_page(page: 1, total: 40)),
      ),
      act: (bloc) => bloc.add(FetchFirstPage()),
      expect: () => [
        isA<PaginationLoading>(),
        isA<PaginationLoaded<_FakeItem>>()
            .having((s) => s.items.length, 'items', 20)
            .having((s) => s.hasReachedMax, 'hasReachedMax', false)
            .having((s) => s.isFetchingMore, 'isFetchingMore', false),
      ],
    );

    blocTest<_FakePaginationBloc, PaginationState<_FakeItem>>(
      'FetchFirstPage emits PaginationEmpty when response has no items',
      build: () => _FakePaginationBloc(
        pageSupplier: (_) async => Right(_page(page: 1, total: 0, items: [])),
      ),
      act: (bloc) => bloc.add(FetchFirstPage()),
      expect: () => [
        isA<PaginationLoading>(),
        isA<PaginationEmpty>(),
      ],
    );

    blocTest<_FakePaginationBloc, PaginationState<_FakeItem>>(
      'FetchFirstPage emits PaginationError on failure',
      build: () => _FakePaginationBloc(
        pageSupplier: (_) async =>
            const Left(ServerFailure(message: 'Server error')),
      ),
      act: (bloc) => bloc.add(FetchFirstPage()),
      expect: () => [
        isA<PaginationLoading>(),
        isA<PaginationError<_FakeItem>>().having(
          (s) => s.previousItems,
          'previousItems',
          isEmpty,
        ),
      ],
    );

    blocTest<_FakePaginationBloc, PaginationState<_FakeItem>>(
      'FetchNextPage appends items and updates total',
      build: () {
        int call = 0;
        return _FakePaginationBloc(
          pageSupplier: (_) async {
            call++;
            return Right(_page(page: call, total: 40));
          },
        );
      },
      act: (bloc) async {
        bloc.add(FetchFirstPage());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(FetchNextPage());
      },
      expect: () => [
        isA<PaginationLoading>(),
        isA<PaginationLoaded<_FakeItem>>()
            .having((s) => s.items.length, 'page1 items', 20),
        isA<PaginationLoaded<_FakeItem>>()
            .having((s) => s.isFetchingMore, 'fetching', true),
        isA<PaginationLoaded<_FakeItem>>()
            .having((s) => s.items.length, 'page1+2 items', 40)
            .having((s) => s.hasReachedMax, 'max reached', true),
      ],
    );

    blocTest<_FakePaginationBloc, PaginationState<_FakeItem>>(
      'FetchNextPage is ignored when hasReachedMax is true',
      build: () => _FakePaginationBloc(
        pageSupplier: (_) async => Right(_page(page: 1, total: 5, items: [
          const _FakeItem(1),
          const _FakeItem(2),
          const _FakeItem(3),
        ])),
      ),
      act: (bloc) async {
        bloc.add(FetchFirstPage());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(FetchNextPage()); // should be ignored
      },
      expect: () => [
        isA<PaginationLoading>(),
        isA<PaginationLoaded<_FakeItem>>()
            .having((s) => s.hasReachedMax, 'max', true),
        // No further states expected
      ],
    );

    blocTest<_FakePaginationBloc, PaginationState<_FakeItem>>(
      'RefreshPage resets to page 1',
      build: () {
        int call = 0;
        return _FakePaginationBloc(
          pageSupplier: (page) async {
            call++;
            return Right(_page(page: page, total: 40));
          },
        );
      },
      act: (bloc) async {
        bloc.add(FetchFirstPage());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(FetchNextPage());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(RefreshPage());
      },
      expect: () => [
        isA<PaginationLoading>(),
        isA<PaginationLoaded<_FakeItem>>().having((s) => s.items.length, 'p1', 20),
        isA<PaginationLoaded<_FakeItem>>().having((s) => s.isFetchingMore, 'fetching', true),
        isA<PaginationLoaded<_FakeItem>>().having((s) => s.items.length, 'p1+p2', 40),
        isA<PaginationLoading>(), // refresh
        isA<PaginationLoaded<_FakeItem>>().having((s) => s.items.length, 'refresh', 20),
      ],
    );
  });
}
