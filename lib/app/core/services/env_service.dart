import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static EnvService? _instance;
  static EnvService get instance => _instance ??= EnvService._();
  
  EnvService._();

  // 환경변수 초기화
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // Firebase Configuration (플랫폼별)
  static String get firebaseApiKey {
    if (kIsWeb) {
      return dotenv.env['FIREBASE_API_KEY_WEB'] ?? '';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['FIREBASE_API_KEY_IOS'] ?? '';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return dotenv.env['FIREBASE_API_KEY_ANDROID'] ?? '';
    }
    return dotenv.env['FIREBASE_API_KEY_WEB'] ?? '';
  }
  
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  
  static String get firebaseAppId {
    if (kIsWeb) {
      return dotenv.env['FIREBASE_APP_ID_WEB'] ?? '';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['FIREBASE_APP_ID_IOS'] ?? '';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? '';
    }
    return dotenv.env['FIREBASE_APP_ID_WEB'] ?? '';
  }

  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseServiceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Order Market App';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // Feature Flags
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  static bool get enableCrashlytics => dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';
  static bool get enablePerformanceMonitoring => dotenv.env['ENABLE_PERFORMANCE_MONITORING']?.toLowerCase() == 'true';

  // Development Settings
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'info';
  static bool get mockData => dotenv.env['MOCK_DATA']?.toLowerCase() == 'true';

  // 환경변수 존재 여부 확인
  static bool hasKey(String key) => dotenv.env.containsKey(key);

  // 환경변수 값 가져오기 (기본값 포함)
  static String getString(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return int.tryParse(dotenv.env[key] ?? '') ?? defaultValue;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return dotenv.env[key]?.toLowerCase() == 'true' || defaultValue;
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return double.tryParse(dotenv.env[key] ?? '') ?? defaultValue;
  }

  // 개발/프로덕션 환경 확인
  static bool get isDevelopment => debugMode;
  static bool get isProduction => !debugMode;

  // 현재 플랫폼 정보
  static String get currentPlatform {
    if (kIsWeb) return 'Web';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'iOS';
    if (defaultTargetPlatform == TargetPlatform.android) return 'Android';
    return 'Unknown';
  }

  // 환경변수 출력 (디버그용 - 민감한 정보 제외)
  static void printEnvironmentInfo() {
    if (debugMode) {
      print('=== Environment Configuration ===');
      print('Platform: $currentPlatform');
      print('App Name: $appName');
      print('App Version: $appVersion');
      print('Debug Mode: $debugMode');
      print('API Base URL: $apiBaseUrl');
      print('API Timeout: $apiTimeout');
      print('Log Level: $logLevel');
      print('Mock Data: $mockData');
      print('Enable Analytics: $enableAnalytics');
      print('Enable Crashlytics: $enableCrashlytics');
      print('Enable Performance Monitoring: $enablePerformanceMonitoring');
      print('Firebase Project ID: $firebaseProjectId');
      print('Firebase API Key: ${firebaseApiKey.isNotEmpty ? 'Configured' : 'Not configured'}');
      print('Supabase URL: ${supabaseUrl.isNotEmpty ? 'Configured' : 'Not configured'}');
      print('================================');
    }
  }
}
