import 'package:get/get.dart';

import 'app_routes.dart';
import '../presentation/views/splash/splash_view.dart';
import '../presentation/views/auth/login_view.dart';
import '../presentation/views/auth/register_view.dart';
import '../presentation/views/auth/role_selection_view.dart';
import '../presentation/views/auth/profile_setup_view.dart';
import '../presentation/views/buyer/buyer_home_view.dart';
import '../presentation/views/buyer/seller_connect_view.dart';
import '../presentation/views/buyer/order_view.dart';
import '../presentation/views/buyer/order_history_view.dart';
import '../presentation/views/seller/seller_home_view.dart';
import '../presentation/views/seller/product_management_view.dart';
import '../presentation/views/seller/seller_orders_view.dart';
import '../presentation/views/seller/connection_requests_view.dart';
import '../presentation/views/profile/profile_view.dart';
import '../presentation/views/main/main_view.dart';

import '../presentation/controllers/splash_controller.dart';
import '../presentation/controllers/auth/login_controller.dart';
import '../presentation/controllers/auth/register_controller.dart';
import '../presentation/controllers/auth/role_selection_controller.dart';
import '../presentation/controllers/auth/profile_setup_controller.dart';
import '../presentation/controllers/buyer/buyer_home_controller.dart';
import '../presentation/controllers/buyer/seller_connect_controller.dart';
import '../presentation/controllers/buyer/order_controller.dart';
import '../presentation/controllers/buyer/order_history_controller.dart';
import '../presentation/controllers/seller/seller_home_controller.dart';
import '../presentation/controllers/seller/product_management_controller.dart';
import '../presentation/controllers/seller/seller_orders_controller.dart';
import '../presentation/controllers/seller/connection_requests_controller.dart';
import '../presentation/controllers/profile/profile_controller.dart';
import '../presentation/controllers/main_controller.dart';

class AppPages {
  static final routes = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
    ),

    // Auth Routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterController>(() => RegisterController());
      }),
    ),

    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RoleSelectionController>(() => RoleSelectionController());
      }),
    ),

    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileSetupController>(() => ProfileSetupController());
      }),
    ),

    // Buyer Routes
    GetPage(
      name: AppRoutes.buyerHome,
      page: () => const BuyerHomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BuyerHomeController>(() => BuyerHomeController());
      }),
    ),

    GetPage(
      name: AppRoutes.sellerConnect,
      page: () => const SellerConnectView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SellerConnectController>(() => SellerConnectController());
      }),
    ),

    // Connection Requests
    GetPage(
      name: AppRoutes.connectionRequests,
      page: () => const ConnectionRequestsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ConnectionRequestsController>(() => ConnectionRequestsController());
      }),
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),

    // Main (with persistent bottom navigation)
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MainController>(() => MainController());
      }),
    ),

    GetPage(
      name: AppRoutes.order,
      page: () => const OrderView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrderController>(() => OrderController());
      }),
    ),

    GetPage(
      name: AppRoutes.orderCreate,
      page: () => const OrderView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrderController>(() => OrderController());
      }),
    ),

    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
      }),
    ),

    // Seller Routes
    GetPage(
      name: AppRoutes.sellerHome,
      page: () => const SellerHomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SellerHomeController>(() => SellerHomeController());
      }),
    ),

    GetPage(
      name: AppRoutes.productManagement,
      page: () => const ProductManagementView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductManagementController>(() => ProductManagementController());
      }),
    ),

    GetPage(
      name: AppRoutes.orderManagement,
      page: () => const SellerOrdersView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SellerOrdersController>(() => SellerOrdersController());
      }),
    ),
  ];
}
