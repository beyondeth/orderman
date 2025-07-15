import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/seller/seller_orders_controller.dart';

class SellerOrdersView extends GetView<SellerOrdersController> {
  const SellerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러가 등록되지 않은 경우 등록
    if (!Get.isRegistered<SellerOrdersController>()) {
      Get.put(SellerOrdersController());
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 관리'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshOrders,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 오늘의 주문 요약
          _buildTodaySummary(),

          // 탭 바
          _buildTabBar(),

          // 주문 목록
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildTodaySummary() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Get.theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 주문 현황',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    '총 주문',
                    '${controller.todayOrders.length}건',
                    Icons.shopping_cart,
                    Get.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _buildSummaryCard(
                    '총 금액',
                    '${controller.todayTotalAmount.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _buildSummaryCard(
                    '대기중',
                    '${controller.todayOrders.where((o) => o.status == OrderStatus.pending).length}건',
                    Icons.hourglass_empty,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: Get.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: Get.textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Get.theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                '오늘 주문',
                controller.selectedTab.value == 0,
                () => controller.selectedTab.value = 0,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                '전체 주문',
                controller.selectedTab.value == 1,
                () => controller.selectedTab.value = 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          border:
              isSelected
                  ? Border(
                    bottom: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  )
                  : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Get.textTheme.titleMedium?.copyWith(
            color:
                isSelected
                    ? Get.theme.colorScheme.primary
                    : Get.theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return Obx(() {
      final orders =
          controller.selectedTab.value == 0
              ? controller.todayOrders
              : controller.allOrders;

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Get.theme.colorScheme.outline,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                controller.selectedTab.value == 0
                    ? '오늘 주문이 없습니다'
                    : '주문 내역이 없습니다',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                '구매자의 주문을 기다려주세요.',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: orders.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(height: AppConstants.smallPadding),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderItem(order);
        },
      );
    });
  }

  Widget _buildOrderItem(OrderModel order) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: order.status.color,
          child: Icon(order.status.icon, color: Colors.white, size: 20),
        ),
        title: Text(
          order.buyerBusinessName ?? order.buyerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate),
              style: Get.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayText,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: order.status.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${order.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  style: Get.textTheme.titleSmall?.copyWith(
                    color: Get.theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing:
            order.status == OrderStatus.pending
                ? PopupMenuButton<OrderStatus>(
                  onSelected:
                      (status) =>
                          controller.updateOrderStatus(order.id, status),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: OrderStatus.confirmed,
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                            ),
                            title: Text('확인'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: OrderStatus.completed,
                          child: ListTile(
                            leading: Icon(Icons.done_all, color: Colors.green),
                            title: Text('완료'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: OrderStatus.cancelled,
                          child: ListTile(
                            leading: Icon(Icons.cancel, color: Colors.red),
                            title: Text('취소'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                )
                : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주문 상품',
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                ...order.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName} (${item.unit})',
                                style: Get.textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${item.quantity}개',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${item.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: Get.theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    '메모',
                    style: Get.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    order.notes!,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
