import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/order_model.dart';
import '../../../routes/app_routes.dart';

class SellerHomeController extends GetxController {
  final OrderService _orderService = OrderService.instance;

  // Reactive variables
  final RxList<OrderModel> todayOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalOrdersToday = 0.obs;
  final RxInt totalAmountToday = 0.obs;

  // 주문 상태별 카운트
  final RxInt pendingOrdersCount = 0.obs;
  final RxInt approvedOrdersCount = 0.obs;
  final RxInt completedOrdersCount = 0.obs;

  // Getters
  UserModel? get currentUser {
    if (Get.isRegistered<AuthService>()) {
      final user = Get.find<AuthService>().userModel;
      print(
        '=== SellerHomeController - Current User: ${user?.displayName} ===',
      );
      print('=== SellerHomeController - User Role: ${user?.role} ===');
      return user;
    }
    print('=== SellerHomeController - AuthService not registered ===');
    return null;
  }

  String get userName {
    final name = currentUser?.displayName ?? '판매자';
    print('=== SellerHomeController - User Name: $name ===');
    return name;
  }

  String get businessName {
    final business = currentUser?.businessName ?? '';
    print('=== SellerHomeController - Business Name: $business ===');
    return business;
  }

  @override
  void onInit() {
    super.onInit();
    _loadTodayOrders();
  }

  // Load today's orders
  Future<void> _loadTodayOrders() async {
    if (currentUser == null) return;

    isLoading.value = true;

    try {
      // Listen to today's orders stream
      _orderService
          .getTodaySellerOrders(currentUser!.uid)
          .listen(
            (orderList) {
              todayOrders.value = orderList;
              totalOrdersToday.value = orderList.length;
              totalAmountToday.value = orderList.fold<int>(
                0,
                (sum, order) => sum + order.totalAmount,
              );

              // 주문 상태별 카운트 계산
              pendingOrdersCount.value =
                  orderList
                      .where((order) => order.status == OrderStatus.pending)
                      .length;
              approvedOrdersCount.value =
                  orderList
                      .where((order) => order.status == OrderStatus.confirmed)
                      .length;
              completedOrdersCount.value =
                  orderList
                      .where((order) => order.status == OrderStatus.completed)
                      .length;

              Get.log('Today orders loaded: ${orderList.length}');
              Get.log(
                'Pending: ${pendingOrdersCount.value}, Approved: ${approvedOrdersCount.value}, Completed: ${completedOrdersCount.value}',
              );
            },
            onError: (error) {
              Get.log('Failed to load today orders: $error');
              Get.snackbar(
                '주문 로딩 실패',
                '오늘의 주문 정보를 불러오는데 실패했습니다.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          );
    } catch (e) {
      Get.log('Error loading today orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh today's orders
  Future<void> refreshTodayOrders() async {
    await _loadTodayOrders();
  }

  // Navigate to product management
  void goToProductManagement() {
    print('=== goToProductManagement called ===');
    try {
      Get.toNamed(AppRoutes.productManagement);
      print('=== Navigation to ${AppRoutes.productManagement} completed ===');
    } catch (e) {
      print('=== Navigation error: $e ===');
      Get.snackbar(
        '네비게이션 오류',
        '상품 관리 화면으로 이동할 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate to order management
  void goToOrderManagement() {
    print('=== goToOrderManagement called ===');
    try {
      Get.toNamed(AppRoutes.orderManagement);
      print('=== Navigation to ${AppRoutes.orderManagement} completed ===');
    } catch (e) {
      print('=== Navigation error: $e ===');
      Get.snackbar(
        '네비게이션 오류',
        '주문 관리 화면으로 이동할 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 프로필 화면으로 이동
  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    await _loadTodayOrders();
  }

  // Navigate to connection requests
  void goToConnectionRequests() {
    print('=== goToConnectionRequests called ===');
    try {
      Get.toNamed(AppRoutes.connectionRequests);
      print('=== Navigation to ${AppRoutes.connectionRequests} completed ===');
    } catch (e) {
      print('=== Navigation error: $e ===');
      Get.snackbar(
        '네비게이션 오류',
        '연결 요청 화면으로 이동할 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate to order detail
  void goToOrderDetail(OrderModel order) {
    print('=== goToOrderDetail called for order: ${order.id} ===');
    try {
      Get.toNamed(AppRoutes.orderDetail, arguments: {'order': order});
      print('=== Navigation to ${AppRoutes.orderDetail} completed ===');
    } catch (e) {
      print('=== Navigation error: $e ===');
      Get.snackbar(
        '네비게이션 오류',
        '주문 상세 화면으로 이동할 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate to settings
  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  // Format amount with comma separator
  String formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        await authService.signOut();
      }
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.log('Sign out failed: $e');
      Get.snackbar(
        '로그아웃 실패',
        '로그아웃 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get greeting message based on time
  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침입니다';
    } else if (hour < 18) {
      return '좋은 오후입니다';
    } else {
      return '좋은 저녁입니다';
    }
  }
}
