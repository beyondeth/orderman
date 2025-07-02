import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/buyer/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 날짜 선택 버튼 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주문 내역',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: controller.showDatePicker,
                tooltip: '월별 조회',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                // 월별 요약
                _buildMonthlySummary(),

                // 주문 목록
                Expanded(child: _buildOrderList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.selectedYear.value}년 ${controller.selectedMonth.value}월',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.isLoadingSummary.value)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    '총 주문',
                    '${controller.totalOrders.value}건',
                    Icons.shopping_cart,
                    Get.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _buildSummaryCard(
                    '총 금액',
                    '${controller.totalAmount.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    Icons.attach_money,
                    Colors.green,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: Get.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: Get.textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.orders.isEmpty) {
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
                '주문 내역이 없습니다',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                '첫 주문을 시작해보세요!',
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
        itemCount: controller.orders.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(height: AppConstants.smallPadding),
        itemBuilder: (context, index) {
          final order = controller.orders[index];
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
          order.sellerBusinessName ?? order.sellerName,
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
