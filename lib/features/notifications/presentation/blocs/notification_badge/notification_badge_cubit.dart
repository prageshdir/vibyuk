import 'dart:async';

import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class NotificationBadgeCubit extends BaseCubit<int> {
  NotificationBadgeCubit(NotificationRepository repository)
      : super(0) {
    _sub = repository.watchUnreadCount().listen(
      emit,
      onError: (_) => emit(0),
    );
  }

  StreamSubscription<int>? _sub;

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
