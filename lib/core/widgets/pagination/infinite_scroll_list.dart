import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/pagination/pagination_bloc.dart';
import 'package:vibyuk/core/pagination/pagination_event.dart';
import 'package:vibyuk/core/pagination/pagination_state.dart';
import 'package:vibyuk/core/widgets/empty/empty_view.dart';
import 'package:vibyuk/core/widgets/error/error_view.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/core/widgets/loaders/skeleton_loader.dart';

class InfiniteScrollList<T, B extends PaginationBloc<T>> extends StatefulWidget {
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget Function()? skeletonBuilder;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int skeletonCount;

  const InfiniteScrollList({
    super.key,
    required this.itemBuilder,
    this.skeletonBuilder,
    this.emptyWidget,
    this.errorWidget,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.skeletonCount = 6,
  });

  @override
  State<InfiniteScrollList<T, B>> createState() => _InfiniteScrollListState<T, B>();
}

class _InfiniteScrollListState<T, B extends PaginationBloc<T>>
    extends State<InfiniteScrollList<T, B>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<B>().add(FetchFirstPage<T>());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final threshold = pos.maxScrollExtent * 0.85;
    if (pos.pixels >= threshold) {
      context.read<B>().add(FetchNextPage<T>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, PaginationState<T>>(
      builder: (context, state) => switch (state) {
        PaginationInitial() => const SizedBox.shrink(),
        PaginationLoading() => SkeletonList(
            itemCount: widget.skeletonCount,
            itemBuilder: widget.skeletonBuilder,
          ),
        PaginationEmpty() =>
          widget.emptyWidget ?? const EmptyView(title: 'Nothing here yet'),
        PaginationError(:final failure, :final previousItems) when previousItems.isEmpty =>
          widget.errorWidget ??
              ErrorView(
                failure: failure,
                onRetry: () => context.read<B>().add(RefreshPage<T>()),
              ),
        PaginationLoaded(:final items, :final isFetchingMore) => RefreshIndicator(
            onRefresh: () async => context.read<B>().add(RefreshPage<T>()),
            child: ListView.builder(
              controller: _scrollController,
              padding: widget.padding,
              shrinkWrap: widget.shrinkWrap,
              physics: widget.physics,
              itemCount: items.length + (isFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: AppLoader(size: 28)),
                  );
                }
                return widget.itemBuilder(context, items[index], index);
              },
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
