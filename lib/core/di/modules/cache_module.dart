import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/core/cache/hive/hive_service.dart';

Future<void> registerCacheModule(GetIt sl) async {
  // Drift database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Hive boxes
  final cacheBox = await HiveService.openBox<String>(HiveBoxNames.userPreferences);
  sl.registerLazySingleton<Box<String>>(() => cacheBox);

  sl.registerLazySingleton<CacheManager>(
    () => CacheManager(sl<Box<String>>()),
  );
}
