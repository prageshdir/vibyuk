import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/empty/empty_view.dart';
import 'package:vibyuk/core/widgets/error/error_view.dart';
import 'package:vibyuk/core/widgets/loaders/skeleton_loader.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';
import 'package:vibyuk/features/notifications/presentation/widgets/notification_filter_bar.dart';
import 'package:vibyuk/features/notifications/presentation/widgets/notification_group_header.dart';
import 'package:vibyuk/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<NotificationCenterBloc>()
        .add(const NotificationCenterLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<NotificationCenterBloc>()
          .add(const NotificationCenterLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _FilterBarSection(),
          const Divider(height: 1),
          Expanded(child: _NotificationListSection(scrollController: _scrollController)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Notifications'),
      centerTitle: false,
      elevation: 0,
      actions: [
        BlocBuilder<NotificationCenterBloc, NotificationCenterState>(
          builder: (context, state) {
            if (state is NotificationCenterLoaded && state.unreadCount > 0) {
              return TextButton(
                onPressed: () => context
                    .read<NotificationCenterBloc>()
                    .add(const NotificationMarkAllReadRequested()),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: const Icon(Icons.tune_outlined),
          tooltip: 'Preferences',
          onPressed: () => context.push(RouteNames.notificationPreferences),
        ),
      ],
    );
  }
}

class _FilterBarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCenterBloc, NotificationCenterState>(
      buildWhen: (prev, curr) {
        if (prev is NotificationCenterLoaded &&
            curr is NotificationCenterLoaded) {
          return prev.activeFilter != curr.activeFilter;
        }
        return false;
      },
      builder: (context, state) {
        final filter = state is NotificationCenterLoaded
            ? state.activeFilter
            : NotificationFilter.all;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: NotificationFilterBar(
            activeFilter: filter,
            onFilterSelected: (f) => context
                .read<NotificationCenterBloc>()
                .add(NotificationCenterFilterChanged(f)),
          ),
        );
      },
    );
  }
}

class _NotificationListSection extends StatelessWidget {
  final ScrollController scrollController;

  const _NotificationListSection({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCenterBloc, NotificationCenterState>(
      builder: (context, state) {
        return switch (state) {
          NotificationCenterInitial() ||
          NotificationCenterLoading() =>
            const _SkeletonList(),
          NotificationCenterLoaded() => _buildList(context, state),
          NotificationCenterError() => ErrorView(
              message: state.failure.message,
              onRetry: () => context
                  .read<NotificationCenterBloc>()
                  .add(const NotificationCenterRefreshRequested()),
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, NotificationCenterLoaded state) {
    if (state.isEmpty) {
      return const EmptyView(
        icon: Icons.notifications_off_outlined,
        title: 'No notifications',
        subtitle: 'You\'re all caught up!',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context
            .read<NotificationCenterBloc>()
            .add(const NotificationCenterRefreshRequested());
        await context.read<NotificationCenterBloc>().stream.firstWhere(
              (s) => s is! NotificationCenterLoading,
            );
      },
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          for (final group in state.groups) ...[
            SliverToBoxAdapter(
              child: NotificationGroupHeader(
                label: group.label,
                unreadCount: group.unreadCount,
              ),
            ),
            SliverList.separated(
              itemCount: group.notifications.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final notification = group.notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => _onTap(context, notification),
                  onDismissed: () => context
                      .read<NotificationCenterBloc>()
                      .add(NotificationDeleteRequested(notification.id)),
                );
              },
            ),
          ],
          if (state.isFetchingMore)
            const SliverToBoxAdapter(child: _FetchMoreIndicator()),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, NotificationEntity notification) {
    context
        .read<NotificationCenterBloc>()
        .add(NotificationMarkReadRequested(notification.id));
    if (notification.deepLink != null) {
      context.push(notification.deepLink!);
    }
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (_, index) => const _NotificationSkeleton(),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    color: AppColors.shimmerBase,
                  ),
                ),
                const SizedBox(height: 6),
                SkeletonLoader(
                  child: Container(
                    height: 12,
                    width: 200,
                    color: AppColors.shimmerBase,
                  ),
                ),
                const SizedBox(height: 6),
                SkeletonLoader(
                  child: Container(
                    height: 12,
                    width: 150,
                    color: AppColors.shimmerBase,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FetchMoreIndicator extends StatelessWidget {
  const _FetchMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
