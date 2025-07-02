class AppConstants {
  // App Info
  static const String appName = '식자재 주문 마켓';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String connectionsCollection = 'connections';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  
  // Shared Preferences Keys
  static const String userRoleKey = 'user_role';
  static const String isFirstLaunchKey = 'is_first_launch';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
