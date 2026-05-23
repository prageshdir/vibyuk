enum AppFlavor { dev, staging, production }

class FlavorConfig {
  final AppFlavor flavor;
  final String name;
  final String baseUrl;
  final String wsUrl;
  final bool enableLogging;
  final bool enableCrashlytics;
  final bool enableAnalytics;
  final bool enablePerformanceMonitoring;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final int maxRetries;

  const FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.baseUrl,
    required this.wsUrl,
    required this.enableLogging,
    required this.enableCrashlytics,
    required this.enableAnalytics,
    required this.enablePerformanceMonitoring,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.maxRetries,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig must be initialized before use.');
    return _instance!;
  }

  static void initialize(AppFlavor flavor) {
    _instance = switch (flavor) {
      AppFlavor.dev => FlavorConfig._(
          flavor: AppFlavor.dev,
          name: 'Development',
          baseUrl: 'https://api-dev.vibyuk.com/v1',
          wsUrl: 'wss://ws-dev.vibyuk.com',
          enableLogging: true,
          enableCrashlytics: false,
          enableAnalytics: false,
          enablePerformanceMonitoring: false,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          maxRetries: 3,
        ),
      AppFlavor.staging => FlavorConfig._(
          flavor: AppFlavor.staging,
          name: 'Staging',
          baseUrl: 'https://api-staging.vibyuk.com/v1',
          wsUrl: 'wss://ws-staging.vibyuk.com',
          enableLogging: true,
          enableCrashlytics: true,
          enableAnalytics: false,
          enablePerformanceMonitoring: true,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          maxRetries: 3,
        ),
      AppFlavor.production => FlavorConfig._(
          flavor: AppFlavor.production,
          name: 'Production',
          baseUrl: 'https://api.vibyuk.com/v1',
          wsUrl: 'wss://ws.vibyuk.com',
          enableLogging: false,
          enableCrashlytics: true,
          enableAnalytics: true,
          enablePerformanceMonitoring: true,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          maxRetries: 3,
        ),
    };
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProduction => flavor == AppFlavor.production;

  @override
  String toString() => 'FlavorConfig($name, $baseUrl)';
}
