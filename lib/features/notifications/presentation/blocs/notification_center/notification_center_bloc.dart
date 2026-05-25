import 'dart:async';

import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_group.dart';
import 'package:vibyuk/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/mark_all_read_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:vibyuk/features/notifications/domain/usecases/save_notification_usecase.dart';

part 'notification_center_event.dart';
part 'notification_center_state.dart';

enum NotificationFilter { all, unread, bookings, chat, payments, campaigns }

class NotificationCenterBloc
    extends BaseBloc<NotificationCenterEvent, NotificationCenterState> {
  NotificationCenterBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markAsRead,
    required MarkAllReadUseCase markAllRead,
    required DeleteNotificationUseCase deleteNotification,
    required SaveNotificationUseCase saveNotification,
    required Stream<int> unreadCountStream,
  })  : _getNotifications = getNotifications,
        _markAsRead = markAsRead,
        _markAllRead = markAllRead,
        _deleteNotification = deleteNotification,
        _saveNotification = saveNotification,
        super(const NotificationCenterInitial()) {
    on<NotificationCenterLoadRequested>(_onLoad);
    on<NotificationCenterRefreshRequested>(_onRefresh);
    on<NotificationCenterLoadMoreRequested>(_onLoadMore);
    on<NotificationCenterFilterChanged>(_onFilterChanged);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
    on<NotificationDeleteRequested>(_onDelete);
    on<NotificationNewIncoming>(_onNewIncoming);

    _unreadSub = unreadCountStream.listen(
      (count) {
        if (state is NotificationCenterLoaded) {
          final loaded = state as NotificationCenterLoaded;
          emit(loaded.copyWith(unreadCount: count));
        }
      },
    );
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markAsRead;
  final MarkAllReadUseCase _markAllRead;
  final DeleteNotificationUseCase _deleteNotification;
  final SaveNotificationUseCase _saveNotification;

  StreamSubscription<int>? _unreadSub;

  static const _perPage = 20;

  // ── Event handlers ──────────────────────────────────────────────────────────

  Future<void> _onLoad(
    NotificationCenterLoadRequested event,
    Emitter<NotificationCenterState> emit,
  ) async {
    emit(const NotificationCenterLoading());
    await _fetchPage(page: 1, filter: NotificationFilter.all, emit: emit);
  }

  Future<void> _onRefresh(
    NotificationCenterRefreshRequested event,
    Emitter<NotificationCenterState> emit,
  ) async {
    final filter = state is NotificationCenterLoaded
        ? (state as NotificationCenterLoaded).activeFilter
        : NotificationFilter.all;
    emit(const NotificationCenterLoading());
    await _fetchPage(page: 1, filter: filter, emit: emit);
  }

  Future<void> _onLoadMore(
    NotificationCenterLoadMoreRequested event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (state is! NotificationCenterLoaded) return;
    final loaded = state as NotificationCenterLoaded;
    if (loaded.isFetchingMore || loaded.hasReachedEnd) return;

    emit(loaded.copyWith(isFetchingMore: true));
    await _fetchPage(
      page: loaded.currentPage + 1,
      filter: loaded.activeFilter,
      emit: emit,
      append: true,
    );
  }

  Future<void> _onFilterChanged(
    NotificationCenterFilterChanged event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (state is NotificationCenterLoaded &&
        (state as NotificationCenterLoaded).activeFilter == event.filter) {
      return;
    }
    emit(const NotificationCenterLoading());
    await _fetchPage(page: 1, filter: event.filter, emit: emit);
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (state is! NotificationCenterLoaded) return;
    final loaded = state as NotificationCenterLoaded;

    await _markAsRead(MarkReadParams(event.notificationId));

    final updatedGroups = _updateEntityInGroups(
      loaded.groups,
      event.notificationId,
      (e) => e.copyWith(isRead: true),
    );
    emit(loaded.copyWith(groups: updatedGroups));
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (state is! NotificationCenterLoaded) return;
    final loaded = state as NotificationCenterLoaded;

    await _markAllRead();

    final updatedGroups = loaded.groups
        .map((g) => g.copyWith(
              notifications: g.notifications
                  .map((n) => n.copyWith(isRead: true))
                  .toList(),
            ))
        .toList();
    emit(loaded.copyWith(groups: updatedGroups, unreadCount: 0));
  }

  Future<void> _onDelete(
    NotificationDeleteRequested event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (state is! NotificationCenterLoaded) return;
    final loaded = state as NotificationCenterLoaded;

    await _deleteNotification(
        DeleteNotificationParams(event.notificationId));

    final updatedGroups = loaded.groups
        .map((g) => g.copyWith(
              notifications: g.notifications
                  .where((n) => n.id != event.notificationId)
                  .toList(),
            ))
        .where((g) => g.notifications.isNotEmpty)
        .toList();
    emit(loaded.copyWith(groups: updatedGroups));
  }

  Future<void> _onNewIncoming(
    NotificationNewIncoming event,
    Emitter<NotificationCenterState> emit,
  ) async {
    // Persist locally
    await _saveNotification(SaveNotificationParams(event.notification));

    if (state is! NotificationCenterLoaded) return;
    final loaded = state as NotificationCenterLoaded;

    // Prepend to the first group (Today) or create a new Today group
    final newGroups = _prependNotification(loaded.groups, event.notification);
    emit(loaded.copyWith(groups: newGroups));
  }

  // ── Core fetch helper ───────────────────────────────────────────────────────

  Future<void> _fetchPage({
    required int page,
    required NotificationFilter filter,
    required Emitter<NotificationCenterState> emit,
    bool append = false,
  }) async {
    final result = await _getNotifications(
      GetNotificationsParams(page: page, perPage: _perPage, filter: filter),
    );

    result.fold(
      (failure) {
        if (append && state is NotificationCenterLoaded) {
          final loaded = state as NotificationCenterLoaded;
          emit(loaded.copyWith(isFetchingMore: false));
        } else {
          emit(NotificationCenterError(failure));
        }
      },
      (paginated) {
        final existingGroups = (append && state is NotificationCenterLoaded)
            ? (state as NotificationCenterLoaded).groups
            : <NotificationGroup>[];

        final allItems = [
          ...existingGroups.expand((g) => g.notifications),
          ...paginated.items,
        ];

        final groups = _groupByDate(allItems);

        emit(NotificationCenterLoaded(
          groups: groups,
          isFetchingMore: false,
          hasReachedEnd: paginated.isLastPage,
          activeFilter: filter,
          currentPage: page,
          unreadCount: state is NotificationCenterLoaded
              ? (state as NotificationCenterLoaded).unreadCount
              : allItems.where((n) => !n.isRead).length,
        ));
      },
    );
  }

  // ── Grouping ────────────────────────────────────────────────────────────────

  List<NotificationGroup> _groupByDate(List<NotificationEntity> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    final Map<String, List<NotificationEntity>> buckets = {};

    for (final item in items) {
      final d = DateTime(
        item.receivedAt.year,
        item.receivedAt.month,
        item.receivedAt.day,
      );
      final String label;
      if (!d.isBefore(today)) {
        label = 'Today';
      } else if (!d.isBefore(yesterday)) {
        label = 'Yesterday';
      } else if (!d.isBefore(weekAgo)) {
        label = 'This Week';
      } else if (!d.isBefore(monthAgo)) {
        label = 'This Month';
      } else {
        label = '${_monthName(d.month)} ${d.year}';
      }
      buckets.putIfAbsent(label, () => []).add(item);
    }

    final groupOrder = ['Today', 'Yesterday', 'This Week', 'This Month'];

    final sorted = buckets.entries.toList()
      ..sort((a, b) {
        final ai = groupOrder.indexOf(a.key);
        final bi = groupOrder.indexOf(b.key);
        if (ai >= 0 && bi >= 0) return ai.compareTo(bi);
        if (ai >= 0) return -1;
        if (bi >= 0) return 1;
        return b.value.first.receivedAt
            .compareTo(a.value.first.receivedAt);
      });

    return sorted
        .map((e) => NotificationGroup(
              label: e.key,
              date: e.value.first.receivedAt,
              notifications: e.value,
            ))
        .toList();
  }

  List<NotificationGroup> _prependNotification(
    List<NotificationGroup> groups,
    NotificationEntity notification,
  ) {
    if (groups.isNotEmpty && groups.first.label == 'Today') {
      final updated = groups.first.copyWith(
        notifications: [notification, ...groups.first.notifications],
      );
      return [updated, ...groups.skip(1)];
    }
    return [
      NotificationGroup(
        label: 'Today',
        date: notification.receivedAt,
        notifications: [notification],
      ),
      ...groups,
    ];
  }

  List<NotificationGroup> _updateEntityInGroups(
    List<NotificationGroup> groups,
    String id,
    NotificationEntity Function(NotificationEntity) updater,
  ) {
    return groups
        .map((g) => g.copyWith(
              notifications: g.notifications
                  .map((n) => n.id == id ? updater(n) : n)
                  .toList(),
            ))
        .toList();
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month];
  }

  @override
  Future<void> close() async {
    await _unreadSub?.cancel();
    return super.close();
  }
}
