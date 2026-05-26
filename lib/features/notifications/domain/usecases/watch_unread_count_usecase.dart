import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/notifications/domain/repositories/notification_repository.dart';

class WatchUnreadCountUseCase implements StreamUseCase<int, NoParams> {
  const WatchUnreadCountUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Stream<dynamic> call(NoParams params) => _repository.watchUnreadCount();
}
