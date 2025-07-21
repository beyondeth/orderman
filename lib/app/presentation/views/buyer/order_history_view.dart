import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_market_app/app/presentation/controllers/main_controller.dart';

import '../../../core/theme/toss_design_system.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/buyer/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TossDesignSystem.spacing20),
      child: Column(
        children: [
          // 날짜 선택 버튼 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주문 내역',
                style: TossDesignSystem.heading3,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month, color: TossDesignSystem.primary),
                onPressed: controller.showDatePicker,
                tooltip: '월별 조회',
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacing20),
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
      () => TossWidgets.card(
        padding: const EdgeInsets.all(TossDesignSystem.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.selectedYear.value}년 ${controller.selectedMonth.value}월',
                  style: TossDesignSystem.heading4,
                ),
                if (controller.isLoadingSummary.value)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: TossDesignSystem.primary),
                  ),
              ],
            ),
            const SizedBox(height: TossDesignSystem.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    '총 주문',
                    '${controller.totalOrders.value}건',
                    Icons.shopping_cart,
                    TossDesignSystem.primary,
                  ),
                ),
                const SizedBox(width: TossDesignSystem.spacing16),
                Expanded(
                  child: _buildSummaryCard(
                    '총 금액',
                    '${NumberFormat('#,###').format(controller.totalAmount.value)}원',
                    Icons.attach_money,
                    TossDesignSystem.success,
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
    return TossWidgets.surfaceCard(
      padding: const EdgeInsets.all(TossDesignSystem.spacing16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: TossDesignSystem.spacing8),
          Text(
            value,
            style: TossDesignSystem.heading4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: TossDesignSystem.body2.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: TossDesignSystem.primary));
      }

      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: TossDesignSystem.gray400,
              ),
              const SizedBox(height: TossDesignSystem.spacing16),
              Text(
                '주문 내역이 없습니다',
                style: TossDesignSystem.heading4.copyWith(color: TossDesignSystem.textSecondary),
              ),
              const SizedBox(height: TossDesignSystem.spacing8),
              Text(
                '첫 주문을 시작해보세요!',
                style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.textTertiary),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(TossDesignSystem.spacing20),
        itemCount: controller.orders.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(height: TossDesignSystem.spacing12),
        itemBuilder: (context, index) {
          final order = controller.orders[index];
          return _buildOrderItem(Get.context!, order);
        },
      );
    });
  }

  Widget _buildOrderItem(BuildContext context, OrderModel order) {
    return GestureDetector(
      onTap: () {
        // 주문 클릭 시 내역 탭으로 이동
        final mainController = Get.find<MainController>();
        mainController.changeTab(2); // 내역 탭으로 이동
      },
      child: TossWidgets.surfaceCard(
        padding: const EdgeInsets.all(TossDesignSystem.spacing16),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: TossDesignSystem.spacing16),
          // leading 제거 (왼쪽 세로 아이콘 삭제)
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 첫 번째 줄: 판매자명, 판매자, 상태를 가로로 나란히 배치 (아이콘 없이)
              Row(
                children: [
                  // 판매자명
                  Text(
                    order.sellerBusinessName ?? order.sellerName,
                    style: TossDesignSystem.body1.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: TossDesignSystem.spacing8),
                  // 판매자 텍스트 (아이콘 삭제)
                  TossWidgets.badge(text: '판매자', backgroundColor: TossDesignSystem.primary.withOpacity(0.1), textColor: TossDesignSystem.primary),
                  const SizedBox(width: TossDesignSystem.spacing8),
                  // 주문 상태 텍스트 (아이콘 삭제)
                  TossWidgets.statusBadge(text: order.status.displayText, color: order.status.color),
                ],
              ),
              const SizedBox(height: TossDesignSystem.spacing8),
              // 두 번째 줄: 주문 날짜와 총 금액
              Row(
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate),
                    style: TossDesignSystem.caption.copyWith(color: TossDesignSystem.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '${NumberFormat('#,###').format(order.totalAmount)}원',
                    style: TossDesignSystem.body1.copyWith(fontWeight: FontWeight.bold, color: TossDesignSystem.primary),
                  ),
                ],
              ),
            ],
          ),
          // 확장 내용 (기존과 동일)
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주문 상품',
                  style: TossDesignSystem.body1.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: TossDesignSystem.spacing8),
                // 주문 상품 목록
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: TossDesignSystem.spacing4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} (${item.unit})',
                            style: TossDesignSystem.body2,
                          ),
                        ),
                        Text(
                          '${item.quantity}개',
                          style: TossDesignSystem.body2.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: TossDesignSystem.spacing16),
                        Text(
                          '${NumberFormat('#,###').format(item.totalPrice)}원',
                          style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.primary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TossDesignSystem.spacing12),
                // 구분선
                const Divider(color: TossDesignSystem.gray200),
                const SizedBox(height: TossDesignSystem.spacing8),
                // 총 금액
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 금액',
                      style: TossDesignSystem.body1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(order.totalAmount)}원',
                      style: TossDesignSystem.heading4.copyWith(color: TossDesignSystem.primary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
