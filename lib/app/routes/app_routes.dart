abstract class AppRoutes {
  // Auth Routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  static const String profileSetup = '/profile-setup';

  // Common Routes
  static const String home = '/home';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Buyer Routes
  static const String buyerHome = '/buyer-home';
  static const String order = '/order';
  static const String orderCreate = '/order-create';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String sellerConnect = '/seller-connect';

  // Seller Routes - Connection
  static const String connectionRequests = '/connection-requests';

  // Seller Routes
  static const String sellerHome = '/seller-home';
  static const String productManagement = '/product-management';
  static const String productCreate = '/product-create';
  static const String productEdit = '/product-edit';
  static const String orderManagement = '/order-management';
  static const String buyerConnect = '/buyer-connect';

  // Shared Routes
  static const String connectionList = '/connection-list';
}
