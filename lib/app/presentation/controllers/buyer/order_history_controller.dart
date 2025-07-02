import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../data/models/order_model.dart';

class OrderHistoryController extends GetxController {
  final OrderService _orderService = OrderService.instance;

  // Reactive variables
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSummary = false.obs;
  
  // Date selection
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  
  // Monthly summary
  final RxInt totalOrders = 0.obs;
  final RxInt totalAmount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
    _loadMonthlySummary();
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
      // Get orders for selected month
      final startDate = DateTime(selectedYear.value, selectedMonth.value, 1);
      final endDate = DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);

      _orderService.getOrdersByDateRange(
        currentUser.uid,
        startDate,
        endDate,
        isSeller: false,
      ).listen(
        (orderList) {
          orders.value = orderList;
          print('=== 📋 Orders loaded: ${orderList.length} ===');
          
          // 실시간으로 집계 계산
          _calculateSummaryFromOrders(orderList);
        },
        onError: (error) {
          print('=== ❌ Failed to load orders: $error ===');
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

  // Calculate summary from loaded orders
  void _calculateSummaryFromOrders(List<OrderModel> orderList) {
    print('=== 🧮 Calculating summary from ${orderList.length} orders ===');
    
    final calculatedTotalOrders = orderList.length;
    final calculatedTotalAmount = orderList.fold<int>(
      0,
      (sum, order) {
        print('=== 💰 Order ${order.id}: ${order.totalAmount}원 ===');
        return sum + order.totalAmount;
      },
    );
    
    print('=== ✅ Calculated: $calculatedTotalOrders orders, $calculatedTotalAmount amount ===');
    
    totalOrders.value = calculatedTotalOrders;
    totalAmount.value = calculatedTotalAmount;
  }

  Future<void> _loadMonthlySummary() async {
    print('=== 📊 Loading monthly summary ===');
    
    // Get current user
    AuthService? authService;
    if (Get.isRegistered<AuthService>()) {
      authService = Get.find<AuthService>();
    }

    if (authService?.userModel == null) {
      print('=== ❌ No user found for monthly summary ===');
      return;
    }

    final currentUser = authService!.userModel!;
    print('=== 👤 Loading summary for user: ${currentUser.uid} ===');
    print('=== 📅 Year: ${selectedYear.value}, Month: ${selectedMonth.value} ===');
    
    isLoadingSummary.value = true;

    try {
      final summary = await _orderService.getMonthlySummary(
        currentUser.uid,
        selectedYear.value,
        selectedMonth.value,
        isSeller: false,
      );

      print('=== 📋 Summary result: $summary ===');

      totalOrders.value = summary['totalOrders'] as int;
      totalAmount.value = summary['totalAmount'] as int;

      print('=== ✅ Monthly summary loaded: ${totalOrders.value} orders, ${totalAmount.value} amount ===');
    } catch (e, stackTrace) {
      print('=== ❌ Error loading monthly summary: $e ===');
      print('=== ❌ Stack trace: $stackTrace ===');
      
      // 기본값 설정
      totalOrders.value = 0;
      totalAmount.value = 0;
    } finally {
      isLoadingSummary.value = false;
    }
  }

  // Change selected month and refresh data
  Future<void> changeMonth(int year, int month) async {
    print('=== 📅 Changing to $year-$month ===');
    selectedYear.value = year;
    selectedMonth.value = month;
    
    // 데이터 새로고침
    await _loadOrders();
    await _loadMonthlySummary();
  }

  // Refresh all data
  Future<void> refreshData() async {
    print('=== 🔄 Refreshing order history data ===');
    await _loadOrders();
    await _loadMonthlySummary();
  }

  Future<void> showDatePicker() async {
    final selectedDate = await Get.dialog<DateTime>(
      AlertDialog(
        title: const Text('월 선택'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: YearPicker(
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            selectedDate: DateTime(selectedYear.value, selectedMonth.value),
            onChanged: (DateTime date) {
              Get.back(result: date);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selectedDate != null) {
      await _showMonthPicker(selectedDate.year);
    }
  }

  Future<void> _showMonthPicker(int year) async {
    final months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];

    final selectedMonthIndex = await Get.dialog<int>(
      AlertDialog(
        title: Text('${year}년 월 선택'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final isSelected = selectedYear.value == year && 
                                selectedMonth.value == index + 1;
              
              return Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () => Get.back(result: index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected 
                        ? Get.theme.colorScheme.primary
                        : null,
                    foregroundColor: isSelected 
                        ? Get.theme.colorScheme.onPrimary
                        : null,
                  ),
                  child: Text(months[index]),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selectedMonthIndex != null) {
      selectedYear.value = year;
      selectedMonth.value = selectedMonthIndex + 1;
      
      await _loadOrders();
      await _loadMonthlySummary();
    }
  }

  Future<void> refreshOrders() async {
    await _loadOrders();
    await _loadMonthlySummary();
  }
}
