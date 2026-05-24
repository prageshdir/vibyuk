import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/notification_item_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/notifications/get_notifications_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/notifications/mark_all_notifications_read_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/notifications/mark_notification_read_use_case.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends BaseBloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markNotificationRead,
    required MarkAllNotificationsReadUseCase markAllNotificationsRead,
  })  : _getNotifications = getNotifications,
        _markRead = markNotificationRead,
        _markAllRead = markAllNotificationsRead,
        super(const NotificationsInitialState()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<LoadMoreNotificationsEvent>(_onLoadMore);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;

  Future<void> _onLoad(
      LoadNotificationsEvent event, Emitter<NotificationsState> emit) async {
    emit(const NotificationsLoadingState());
    final result = await _getNotifications(
        GetNotificationsParams(unreadOnly: event.unreadOnly));
    result.fold(
      (f) => emit(NotificationsErrorState(failure: f)),
      (page) => emit(NotificationsLoadedState(
        notifications: page.items,
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        unreadCount: page.items.where((n) => !n.isRead).length,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMoreNotificationsEvent event, Emitter<NotificationsState> emit) async {
    if (state is! NotificationsLoadedState) return;
    final loaded = state as NotificationsLoadedState;
    if (!loaded.hasMore || loaded.isLoadingMore) return;

    emit(loaded.copyWith(isLoadingMore: true));
    final result = await _getNotifications(
        GetNotificationsParams(page: loaded.currentPage + 1));
    result.fold(
      (f) => emit(NotificationsErrorState(failure: f)),
      (page) => emit(loaded.copyWith(
        notifications: [...loaded.notifications, ...page.items],
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onMarkRead(
      MarkNotificationReadEvent event, Emitter<NotificationsState> emit) async {
    await _markRead(
        MarkNotificationReadParams(notificationId: event.notificationId));
    if (state is NotificationsLoadedState) {
      final loaded = state as NotificationsLoadedState;
      final updated = loaded.notifications.map((n) {
        if (n.id == event.notificationId) return n.markRead();
        return n;
      }).toList();
      emit(loaded.copyWith(
        notifications: updated,
        unreadCount: (loaded.unreadCount - 1).clamp(0, loaded.unreadCount),
      ));
    }
  }

  Future<void> _onMarkAllRead(
      MarkAllNotificationsReadEvent event, Emitter<NotificationsState> emit) async {
    await _markAllRead();
    if (state is NotificationsLoadedState) {
      final loaded = state as NotificationsLoadedState;
      emit(loaded.copyWith(
        notifications: loaded.notifications.map((n) => n.markRead()).toList(),
        unreadCount: 0,
      ));
    }
  }
}
