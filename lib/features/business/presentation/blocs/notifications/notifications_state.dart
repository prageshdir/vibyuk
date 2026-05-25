part of 'notifications_bloc.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();
}

class NotificationsInitialState extends NotificationsState {
  const NotificationsInitialState();
  @override
  List<Object?> get props => [];
}

class NotificationsLoadingState extends NotificationsState {
  const NotificationsLoadingState();
  @override
  List<Object?> get props => [];
}

class NotificationsLoadedState extends NotificationsState {
  const NotificationsLoadedState({
    required this.notifications,
    required this.hasMore,
    required this.currentPage,
    required this.unreadCount,
    this.isLoadingMore = false,
  });

  final List<NotificationItemEntity> notifications;
  final bool hasMore;
  final int currentPage;
  final int unreadCount;
  final bool isLoadingMore;

  NotificationsLoadedState copyWith({
    List<NotificationItemEntity>? notifications,
    bool? hasMore,
    int? currentPage,
    int? unreadCount,
    bool? isLoadingMore,
  }) =>
      NotificationsLoadedState(
        notifications: notifications ?? this.notifications,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        unreadCount: unreadCount ?? this.unreadCount,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props =>
      [notifications, hasMore, currentPage, unreadCount, isLoadingMore];
}

class NotificationsErrorState extends NotificationsState {
  const NotificationsErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
