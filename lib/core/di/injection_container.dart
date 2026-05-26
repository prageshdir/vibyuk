import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/cache/hive/hive_service.dart';
import 'package:vibyuk/core/di/modules/admin_module.dart';
import 'package:vibyuk/core/di/modules/ai_module.dart';
import 'package:vibyuk/core/di/modules/api_module.dart';
import 'package:vibyuk/core/di/modules/auth_module.dart';
import 'package:vibyuk/core/di/modules/booking_engine_module.dart';
import 'package:vibyuk/core/di/modules/business_module.dart';
import 'package:vibyuk/core/di/modules/cache_module.dart';
import 'package:vibyuk/core/di/modules/chat_module.dart';
import 'package:vibyuk/core/di/modules/core_module.dart';
import 'package:vibyuk/core/di/modules/creator_module.dart';
import 'package:vibyuk/core/di/modules/profile_module.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/notifications/local_notification_service.dart';
import 'package:vibyuk/core/notifications/notification_handler.dart';
import 'package:vibyuk/core/utils/helpers/connectivity_helper.dart';
import 'package:vibyuk/core/di/modules/services_module.dart';
import 'package:vibyuk/features/events/di/event_module.dart';
import 'package:vibyuk/features/notifications/di/notification_module.dart';
import 'package:vibyuk/features/tourism/di/tourism_module.dart';
import 'package:vibyuk/features/wedding/di/wedding_module.dart';
import 'package:vibyuk/features/subscriptions/di/subscription_module.dart';
import 'package:vibyuk/core/di/modules/influencer_module.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  AppLogger.info('DI: Initializing dependency container');

  // Infrastructure
  await HiveService.initialize();

  // Modules — order matters: core → cache → api → features
  registerCoreModule(sl);
  await registerCacheModule(sl);
  registerApiModule(sl);
  registerServicesModule(sl);

  // Feature modules
  registerAuthModule(sl);
  registerProfileModule(sl);
  registerBusinessModule(sl);
  registerCreatorModule(sl);
  registerBookingEngineModule(sl);
  registerChatModule(sl);
  registerNotificationModule(sl);
  registerEventModule(sl);
  registerWeddingModule(sl);
  registerTourismModule(sl);
  registerAiModule(sl);
  registerAdminModule(sl);
  registerSubscriptionModule(sl);
  registerInfluencerModule(sl);

  // Bootstrap services
  await sl<ConnectivityHelper>().initialize();

  await LocalNotificationService.initialize(
    onNotificationTap: (payload) {
      if (payload != null) sl<NotificationHandler>().handleLocalTap(payload);
    },
  );

  AppLogger.info('DI: Container initialized successfully');
}
