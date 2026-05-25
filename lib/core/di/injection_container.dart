import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/cache/hive/hive_service.dart';
import 'package:vibyuk/core/di/modules/ai_module.dart';
import 'package:vibyuk/core/di/modules/api_module.dart';
import 'package:vibyuk/core/di/modules/cache_module.dart';
import 'package:vibyuk/core/di/modules/core_module.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/utils/helpers/connectivity_helper.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  AppLogger.info('DI: Initializing dependency container');

  // Infrastructure
  await HiveService.initialize();

  // Modules — order matters: core → cache → api → features
  registerCoreModule(sl);
  await registerCacheModule(sl);
  registerApiModule(sl);

  // Feature modules registered here as they are built:
  // registerAuthModule(sl);
  // registerCreatorModule(sl);
  // registerEventModule(sl);
  registerAiModule(sl);

  // Bootstrap connectivity watcher
  await sl<ConnectivityHelper>().initialize();

  AppLogger.info('DI: Container initialized successfully');
}
