import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../data/models/order_model.dart';

class SellerOrdersController extends GetxController {
  final OrderService _orderService = OrderService.instance;

  // Reactive variables
  final RxList<OrderModel> todayOrders = <OrderModel>[].obs;
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;
  final RxInt todayTotalAmount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
    
    // Listen to today orders changes to calculate total
    ever(todayOrders, (_) => _calculateTodayTotal());
  }

  Future<void> _loadOrders() async {
    // Get current user
    AuthService? authService;
    if (Get.isRegistered<AuthService>()) {
      authService = Get.find<AuthService>();
    }

    if (authService?.userModel == null) {
      Get.snackbar(
        '사용자 정보 없음',
        '로그인 정보를 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final currentUser = authService!.userModel!;
    isLoading.value = true;

    try {
      // Load today's orders
      _orderService.getTodaySellerOrders(currentUser.uid).listen(
        (orderList) {
          todayOrders.value = orderList;
          Get.log('Today orders loaded: ${orderList.length}');
        },
        onError: (error) {
          Get.log('Failed to load today orders: $error');
          Get.snackbar(
            '오늘 주문 로딩 실패',
            '오늘 주문을 불러오는데 실패했습니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );

      // Load all orders
      _orderService.getSellerOrders(currentUser.uid).listen(
        (orderList) {
          allOrders.value = orderList;
          Get.log('All orders loaded: ${orderList.length}');
        },
        onError: (error) {
          Get.log('Failed to load all orders: $error');
          Get.snackbar(
            '주문 내역 로딩 실패',
            '주문 내역을 불러오는데 실패했습니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      Get.log('Error loading orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateTodayTotal() {
    final total = todayOrders.fold<int>(0, (sum, order) => sum + order.totalAmount);
    todayTotalAmount.value = total;
    Get.log('Today total amount calculated: $total');
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final success = await _orderService.updateOrderStatus(orderId, status);
      
      if (success) {
        Get.snackbar(
          '주문 상태 변경',
          '주문 상태가 ${status.displayText}(으)로 변경되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.log('Failed to update order status: $e');
    }
  }

  Future<void> refreshOrders() async {
    await _loadOrders();
  }
}
