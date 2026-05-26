import 'dart:async';

import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/notifications/domain/usecases/watch_unread_count_usecase.dart';

class NotificationBadgeCubit extends BaseCubit<int> {
  NotificationBadgeCubit(WatchUnreadCountUseCase watchUnreadCount)
      : super(0) {
    _sub = watchUnreadCount(NoParams()).listen(
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
