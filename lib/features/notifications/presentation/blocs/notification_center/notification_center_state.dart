part of 'notification_center_bloc.dart';

sealed class NotificationCenterState {
  const NotificationCenterState();
}

final class NotificationCenterInitial extends NotificationCenterState {
  const NotificationCenterInitial();
}

final class NotificationCenterLoading extends NotificationCenterState {
  const NotificationCenterLoading();
}

final class NotificationCenterLoaded extends NotificationCenterState {
  final List<NotificationGroup> groups;
  final bool isFetchingMore;
  final bool hasReachedEnd;
  final NotificationFilter activeFilter;
  final int unreadCount;
  final int currentPage;

  const NotificationCenterLoaded({
    required this.groups,
    this.isFetchingMore = false,
    this.hasReachedEnd = false,
    this.activeFilter = NotificationFilter.all,
    this.unreadCount = 0,
    this.currentPage = 1,
  });

  List<NotificationEntity> get allItems =>
      groups.expand((g) => g.notifications).toList();

  bool get isEmpty => groups.isEmpty;

  NotificationCenterLoaded copyWith({
    List<NotificationGroup>? groups,
    bool? isFetchingMore,
    bool? hasReachedEnd,
    NotificationFilter? activeFilter,
    int? unreadCount,
    int? currentPage,
  }) {
    return NotificationCenterLoaded(
      groups: groups ?? this.groups,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      activeFilter: activeFilter ?? this.activeFilter,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

final class NotificationCenterError extends NotificationCenterState {
  final Failure failure;
  const NotificationCenterError(this.failure);
}
