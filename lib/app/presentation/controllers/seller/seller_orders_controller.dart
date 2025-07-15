import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../data/models/order_model.dart';

enum DateFilterType {
  today('오늘'),
  week('최근 일주일'),
  month('최근 한달'),
  threeMonths('최근 3개월'),
  custom('기간 선택');

  const DateFilterType(this.displayText);
  final String displayText;
}

class SellerOrdersController extends GetxController {
  final OrderService _orderService = OrderService.instance;

  // Reactive variables
  final RxList<OrderModel> todayOrders = <OrderModel>[].obs;
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxList<OrderModel> filteredOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;
  final RxInt todayTotalAmount = 0.obs;
  
  // 필터 관련 변수
  final Rx<DateFilterType> currentFilter = DateFilterType.today.obs;
  final Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> customEndDate = Rx<DateTime?>(null);
  
  // 상태별 카운트
  final RxInt todayPendingCount = 0.obs;
  final RxInt todayApprovedCount = 0.obs;
  final RxInt todayCompletedCount = 0.obs;

  // Getters
  List<OrderModel> get orders => filteredOrders;
  String get filterDisplayText {
    if (currentFilter.value == DateFilterType.custom && 
        customStartDate.value != null && 
        customEndDate.value != null) {
      final start = customStartDate.value!;
      final end = customEndDate.value!;
      return '${start.month}/${start.day} - ${end.month}/${end.day}';
    }
    return currentFilter.value.displayText;
  } // allOrders → todayOrders로 변경

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
    
    // Listen to today orders changes to calculate total and counts
    ever(todayOrders, (_) {
      _calculateTodayTotal();
      _calculateStatusCounts();
    });
    
    // Listen to all orders changes to apply filter
    ever(allOrders, (_) => _applyCurrentFilter());
    
    // Listen to filter changes
    ever(currentFilter, (_) => _applyCurrentFilter());
    ever(customStartDate, (_) => _applyCurrentFilter());
    ever(customEndDate, (_) => _applyCurrentFilter());
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

  void _calculateStatusCounts() {
    todayPendingCount.value = todayOrders.where((order) => order.status == OrderStatus.pending).length;
    todayApprovedCount.value = todayOrders.where((order) => order.status == OrderStatus.confirmed).length;
    todayCompletedCount.value = todayOrders.where((order) => order.status == OrderStatus.completed).length;
    
    Get.log('Status counts - Pending: ${todayPendingCount.value}, Confirmed: ${todayApprovedCount.value}, Completed: ${todayCompletedCount.value}');
  }

  // 전체 주문 기준 카운트 (필요시 사용)
  void _calculateAllStatusCounts() {
    todayPendingCount.value = allOrders.where((order) => order.status == OrderStatus.pending).length;
    todayApprovedCount.value = allOrders.where((order) => order.status == OrderStatus.confirmed).length;
    todayCompletedCount.value = allOrders.where((order) => order.status == OrderStatus.completed).length;
    
    Get.log('All Status counts - Pending: ${todayPendingCount.value}, Confirmed: ${todayApprovedCount.value}, Completed: ${todayCompletedCount.value}');
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

  // 필터 적용 메서드
  void _applyCurrentFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<OrderModel> filtered = [];
    
    switch (currentFilter.value) {
      case DateFilterType.today:
        final tomorrow = today.add(const Duration(days: 1));
        filtered = allOrders.where((order) => 
          order.orderDate.isAfter(today) && 
          order.orderDate.isBefore(tomorrow)
        ).toList();
        break;
        
      case DateFilterType.week:
        final weekAgo = today.subtract(const Duration(days: 7));
        filtered = allOrders.where((order) => 
          order.orderDate.isAfter(weekAgo)
        ).toList();
        break;
        
      case DateFilterType.month:
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        filtered = allOrders.where((order) => 
          order.orderDate.isAfter(monthAgo)
        ).toList();
        break;
        
      case DateFilterType.threeMonths:
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        filtered = allOrders.where((order) => 
          order.orderDate.isAfter(threeMonthsAgo)
        ).toList();
        break;
        
      case DateFilterType.custom:
        if (customStartDate.value != null && customEndDate.value != null) {
          final start = customStartDate.value!;
          final end = customEndDate.value!.add(const Duration(days: 1)); // 종료일 포함
          filtered = allOrders.where((order) => 
            order.orderDate.isAfter(start) && 
            order.orderDate.isBefore(end)
          ).toList();
        } else {
          filtered = allOrders;
        }
        break;
    }
    
    // 최신 순으로 정렬
    filtered.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    filteredOrders.assignAll(filtered);
    
    Get.log('Filter applied: ${currentFilter.value.displayText}, Orders: ${filtered.length}');
  }

  // 필터 변경 메서드들
  void setFilter(DateFilterType filter) {
    currentFilter.value = filter;
  }

  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    customStartDate.value = startDate;
    customEndDate.value = endDate;
    currentFilter.value = DateFilterType.custom;
  }

  void resetToToday() {
    currentFilter.value = DateFilterType.today;
    customStartDate.value = null;
    customEndDate.value = null;
  }
}
