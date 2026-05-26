import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';
import 'package:vibyuk/features/business/presentation/widgets/notification_tile.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends State<NotificationCenterScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const LoadNotificationsEvent());
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context
          .read<NotificationsBloc>()
          .add(const LoadMoreNotificationsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            final unread = state is NotificationsLoadedState
                ? state.unreadCount
                : 0;
            return Row(
              children: [
                const Text('Notifications',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoadedState &&
                  state.unreadCount > 0) {
                return TextButton(
                  onPressed: () => context
                      .read<NotificationsBloc>()
                      .add(const MarkAllNotificationsReadEvent()),
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) => switch (state) {
          NotificationsLoadingState() =>
            const Center(child: AppLoader()),
          NotificationsLoadedState(
            :final notifications,
            :final isLoadingMore
          ) =>
            notifications.isEmpty
                ? const BusinessEmptyState.noNotifications()
                : RefreshIndicator(
                    onRefresh: () async => context
                        .read<NotificationsBloc>()
                        .add(const LoadNotificationsEvent()),
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: notifications.length +
                          (isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index == notifications.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: AppLoader(size: 24)),
                          );
                        }
                        final notif = notifications[index];
                        return NotificationTile(
                          notification: notif,
                          onMarkRead: () => context
                              .read<NotificationsBloc>()
                              .add(MarkNotificationReadEvent(
                                  notificationId: notif.id)),
                        );
                      },
                    ),
                  ),
          NotificationsErrorState(:final failure) =>
            BusinessEmptyState(
              title: 'Failed to load notifications',
              description: failure.message,
              icon: Icons.notifications_off_rounded,
              actionLabel: 'Retry',
              onAction: () => context
                  .read<NotificationsBloc>()
                  .add(const LoadNotificationsEvent()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
