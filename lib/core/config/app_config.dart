import 'package:vibyuk/core/config/flavor_config.dart';

class AppConfig {
  static const String appName = 'VIBYUK';
  static const String appTagline = 'Create. Collaborate. Vibe.';
  static const String packageName = 'com.vibyuk.app';

  // API versioning
  static const String apiVersion = 'v1';
  static const int apiPageSize = 20;
  static const int apiMaxPageSize = 100;

  // Token config
  static const String accessTokenKey = 'vibyuk_access_token';
  static const String refreshTokenKey = 'vibyuk_refresh_token';
  static const String userDataKey = 'vibyuk_user_data';
  static const String biometricEnabledKey = 'vibyuk_biometric_enabled';
  static const String roleSelectedKey = 'vibyuk_role_selected';

  // Cache config
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(minutes: 15);

  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int defaultPrefetchOffset = 5;

  // Retry config
  static const int maxAuthRetries = 1;

  // Deep link scheme
  static const String deepLinkScheme = 'vibyuk';
  static const String deepLinkHost = 'app.vibyuk.com';

  // Supported locales
  static const List<String> supportedLocales = ['en', 'es', 'fr', 'de'];
  static const String defaultLocale = 'en';

  static FlavorConfig get flavor => FlavorConfig.instance;

  AppConfig._();
}
