import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/config/app_config.dart';
import 'package:vibyuk/core/pagination/pagination_bloc.dart';
import 'package:vibyuk/core/pagination/pagination_event.dart';
import 'package:vibyuk/core/pagination/pagination_state.dart';
import 'package:vibyuk/core/widgets/empty/empty_view.dart';
import 'package:vibyuk/core/widgets/error/error_view.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/core/widgets/loaders/skeleton_loader.dart';

class InfiniteScrollList<T, B extends PaginationBloc<T>> extends StatefulWidget {
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
    this.scrollThreshold = 0.85,
    this.scrollDebounce = const Duration(milliseconds: 200),
    this.separatorBuilder,
    this.header,
    this.addRepaintBoundaries = true,
    this.addAutomaticKeepAlives = true,
  });

  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget Function()? skeletonBuilder;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int skeletonCount;

  /// Fraction of maxScrollExtent at which the next page is triggered (0–1).
  final double scrollThreshold;

  /// Debounce for scroll events to avoid hammering the BLoC.
  final Duration scrollDebounce;

  /// Optional separator rendered between items.
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Sliver header pinned above the list (e.g. search bar).
  final Widget? header;

  /// Paint boundaries around each item to reduce repaint scope.
  final bool addRepaintBoundaries;

  /// Keep alive off-screen items (use for tabs, not plain lists).
  final bool addAutomaticKeepAlives;

  @override
  State<InfiniteScrollList<T, B>> createState() =>
      _InfiniteScrollListState<T, B>();
}

class _InfiniteScrollListState<T, B extends PaginationBloc<T>>
    extends State<InfiniteScrollList<T, B>> {
  final _scrollController = ScrollController();
  Timer? _debounce;
  bool _hasTriggeredFetch = false;

  @override
  void initState() {
    super.initState();
    context.read<B>().add(FetchFirstPage<T>());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) return;
    _debounce = Timer(widget.scrollDebounce, () {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      final threshold = pos.maxScrollExtent * widget.scrollThreshold;
      if (pos.pixels >= threshold && !_hasTriggeredFetch) {
        _hasTriggeredFetch = true;
        context.read<B>().add(FetchNextPage<T>());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, PaginationState<T>>(
      listener: (_, state) {
        // Re-arm fetch trigger once a page load completes
        if (state is PaginationLoaded<T>) {
          _hasTriggeredFetch = false;
        }
      },
      builder: (context, state) => switch (state) {
        PaginationInitial() => const SizedBox.shrink(),
        PaginationLoading() => SkeletonList(
            itemCount: widget.skeletonCount,
            itemBuilder: widget.skeletonBuilder,
          ),
        PaginationEmpty() =>
          widget.emptyWidget ?? const EmptyView(title: 'Nothing here yet'),
        PaginationError(:final failure, :final previousItems)
            when previousItems.isEmpty =>
          widget.errorWidget ??
              ErrorView(
                failure: failure,
                onRetry: () => context.read<B>().add(RefreshPage<T>()),
              ),
        PaginationLoaded(:final items, :final isFetchingMore) =>
          _buildList(context, items, isFetchingMore),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildList(BuildContext context, List<T> items, bool isFetchingMore) {
    final itemCount = items.length + (isFetchingMore ? 1 : 0);

    Widget listView = widget.separatorBuilder != null
        ? ListView.separated(
            controller: _scrollController,
            padding: widget.padding,
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics,
            itemCount: itemCount,
            separatorBuilder: (ctx, i) => i < items.length
                ? widget.separatorBuilder!(ctx, i)
                : const SizedBox.shrink(),
            itemBuilder: (ctx, i) => _buildItem(ctx, items, isFetchingMore, i),
          )
        : ListView.builder(
            controller: _scrollController,
            padding: widget.padding,
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
            itemCount: itemCount,
            itemBuilder: (ctx, i) => _buildItem(ctx, items, isFetchingMore, i),
          );

    return RefreshIndicator(
      onRefresh: () async => context.read<B>().add(RefreshPage<T>()),
      child: listView,
    );
  }

  Widget _buildItem(
    BuildContext context,
    List<T> items,
    bool isFetchingMore,
    int index,
  ) {
    if (index == items.length) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: AppLoader(size: 28)),
      );
    }
    return widget.itemBuilder(context, items[index], index);
  }
}
