import 'package:hive_flutter/hive_flutter.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

class HiveService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    // Register adapters here as models are added:
    // Hive.registerAdapter(SomeModelAdapter());
    _initialized = true;
    AppLogger.info('Hive initialized');
  }

  static Future<Box<T>> openBox<T>(String name) async {
    try {
      if (Hive.isBoxOpen(name)) return Hive.box<T>(name);
      return await Hive.openBox<T>(name);
    } catch (e, st) {
      AppLogger.error('Failed to open Hive box: $name', error: e, stackTrace: st);
      throw CacheException(message: 'Failed to open cache box: $name');
    }
  }

  static Future<LazyBox<T>> openLazyBox<T>(String name) async {
    try {
      if (Hive.isBoxOpen(name)) return Hive.lazyBox<T>(name);
      return await Hive.openLazyBox<T>(name);
    } catch (e, st) {
      AppLogger.error('Failed to open lazy Hive box: $name', error: e, stackTrace: st);
      throw CacheException(message: 'Failed to open lazy cache box: $name');
    }
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}

abstract final class HiveBoxNames {
  static const String userPreferences = 'user_preferences';
  static const String draftContent = 'draft_content';
  static const String recentSearches = 'recent_searches';
  static const String cachedFeed = 'cached_feed';
}
