import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/cache/hive/hive_service.dart';
import 'package:vibyuk/core/di/modules/api_module.dart';
import 'package:vibyuk/core/di/modules/cache_module.dart';
import 'package:vibyuk/core/di/modules/core_module.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/notifications/local_notification_service.dart';
import 'package:vibyuk/core/notifications/notification_handler.dart';
import 'package:vibyuk/core/utils/helpers/connectivity_helper.dart';
import 'package:vibyuk/features/events/di/event_module.dart';
import 'package:vibyuk/features/notifications/di/notification_module.dart';
import 'package:vibyuk/features/wedding/di/wedding_module.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  AppLogger.info('DI: Initializing dependency container');

  // Infrastructure
  await HiveService.initialize();

  // Modules — order matters: core → cache → api → features
  registerCoreModule(sl);
  await registerCacheModule(sl);
  registerApiModule(sl);

  // Feature modules
  registerNotificationModule(sl);
  // registerAuthModule(sl);
  // registerCreatorModule(sl);
  registerEventModule(sl);
  registerWeddingModule(sl);

  // Bootstrap services
  await sl<ConnectivityHelper>().initialize();

  await LocalNotificationService.initialize(
    onNotificationTap: (payload) {
      if (payload != null) sl<NotificationHandler>().handleLocalTap(payload);
    },
  );

  AppLogger.info('DI: Container initialized successfully');
}
