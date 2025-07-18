import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/toss_design_system.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/seller/seller_orders_controller.dart';
import '../common/toss_calendar_widget.dart';

class SellerOrdersView extends GetView<SellerOrdersController> {
  const SellerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러가 등록되지 않은 경우 등록
    if (!Get.isRegistered<SellerOrdersController>()) {
      Get.put(SellerOrdersController());
      print('=== SellerOrdersView: SellerOrdersController 등록 완료 ===');
    }

    return Scaffold(
      backgroundColor: TossDesignSystem.background,
      appBar: AppBar(
        title: Text('주문 관리', style: TossDesignSystem.heading4),
        backgroundColor: TossDesignSystem.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          TossWidgets.iconButton(
            icon: Icons.refresh_rounded,
            onPressed: controller.refreshOrders,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: TossDesignSystem.spacing12),
        ],
      ),
      body: Column(
        children: [
          // 오늘의 주문 요약
          _buildTodaySummary(),

          // 주문 목록
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: TossDesignSystem.primary,
                  ),
                );
              }

              if (controller.orders.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(TossDesignSystem.spacing20),
                itemCount: controller.orders.length,
                separatorBuilder:
                    (context, index) =>
                        const SizedBox(height: TossDesignSystem.spacing16),
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  return _buildOrderCard(order);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 오늘의 주문 요약
  Widget _buildTodaySummary() {
    return Container(
      margin: const EdgeInsets.all(TossDesignSystem.spacing20),
      child: TossWidgets.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      TossDesignSystem.radius8,
                    ),
                  ),
                  child: const Icon(
                    Icons.today_rounded,
                    color: TossDesignSystem.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: TossDesignSystem.spacing12),
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.filterDisplayText,
                      style: TossDesignSystem.heading4,
                    ),
                  ),
                ),
                // 필터 버튼
                TossWidgets.iconButton(
                  icon: Icons.filter_list_rounded,
                  onPressed: _showFilterBottomSheet,
                  backgroundColor: TossDesignSystem.gray100,
                  iconColor: TossDesignSystem.primary,
                ),
              ],
            ),
            const SizedBox(height: TossDesignSystem.spacing20),

            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      '신규 주문',
                      controller.filteredPendingCount.value,
                      TossDesignSystem.warning,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: TossDesignSystem.gray200,
                  ),
                  const SizedBox(width: TossDesignSystem.spacing16),
                  Expanded(
                    child: _buildSummaryItem(
                      '주문확인',
                      controller.filteredApprovedCount.value,
                      TossDesignSystem.info,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: TossDesignSystem.gray200,
                  ),
                  const SizedBox(width: TossDesignSystem.spacing16),
                  Expanded(
                    child: _buildSummaryItem(
                      '배송완료',
                      controller.filteredCompletedCount.value,
                      TossDesignSystem.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TossDesignSystem.heading3.copyWith(color: color),
        ),
        const SizedBox(height: TossDesignSystem.spacing4),
        Text(
          title,
          style: TossDesignSystem.caption.copyWith(
            color: TossDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TossDesignSystem.spacing40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(TossDesignSystem.radius20),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: TossDesignSystem.gray400,
              ),
            ),
            const SizedBox(height: TossDesignSystem.spacing24),
            Text(
              '주문이 없어요',
              style: TossDesignSystem.heading4.copyWith(
                color: TossDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: TossDesignSystem.spacing8),
            Text(
              '새로운 주문이 들어오면 알려드릴게요',
              style: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 주문 카드
  Widget _buildOrderCard(OrderModel order) {
    return TossWidgets.card(
      padding: const EdgeInsets.all(TossDesignSystem.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주문 헤더
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.buyerBusinessName ?? order.buyerName,
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: TossDesignSystem.spacing4),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate),
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TossWidgets.statusBadge(
                    text: _getStatusText(order.status),
                    color: _getStatusColor(order.status),
                  ),
                  const SizedBox(height: TossDesignSystem.spacing4),
                  Text(
                    '${_formatAmount(order.totalAmount)}원',
                    style: TossDesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TossDesignSystem.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: TossDesignSystem.spacing16),

          // 주문 상품 목록
          Container(
            padding: const EdgeInsets.all(TossDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: TossDesignSystem.textSecondary,
                    ),
                    const SizedBox(width: TossDesignSystem.spacing8),
                    Text(
                      '주문 상품',
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TossDesignSystem.spacing12),

                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: TossDesignSystem.spacing8,
                    ),
                    child: Row(
                      children: [
                        // 상품명 + 단위 (좌측, 확장)
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${item.productName}${item.unit.isNotEmpty ? ' (${item.unit})' : ''}',
                            style: TossDesignSystem.body2,
                            overflow: TextOverflow.ellipsis, // 긴 이름도 말줄임
                          ),
                        ),

                        // 수량 (중간, 고정 너비 + 우측 정렬)
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${item.quantity}개',
                            textAlign: TextAlign.right,
                            style: TossDesignSystem.body2.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // 가격 좌우 여백
                        const SizedBox(width: TossDesignSystem.spacing16),

                        // 가격 (우측, 고정 너비 + 우측 정렬)
                        SizedBox(
                          width: 64,
                          child: Text(
                            '${_formatAmount(item.totalPrice ?? 0)}원',
                            textAlign: TextAlign.right,
                            style: TossDesignSystem.body2.copyWith(
                              color: TossDesignSystem.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 메모가 있는 경우 표시
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: TossDesignSystem.spacing12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TossDesignSystem.spacing12),
              decoration: BoxDecoration(
                color: TossDesignSystem.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: TossDesignSystem.info,
                      ),
                      const SizedBox(width: TossDesignSystem.spacing4),
                      Text(
                        '메모',
                        style: TossDesignSystem.caption.copyWith(
                          color: TossDesignSystem.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TossDesignSystem.spacing4),
                  Text(
                    order.notes!,
                    style: TossDesignSystem.body2.copyWith(
                      color: TossDesignSystem.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: TossDesignSystem.spacing20),

          // 액션 버튼들
          _buildActionButtons(order),
        ],
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons(OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showRejectDialog(order),
                style: TossDesignSystem.outlineButton.copyWith(
                  foregroundColor: MaterialStateProperty.all(
                    TossDesignSystem.error,
                  ),
                  side: MaterialStateProperty.all(
                    const BorderSide(color: TossDesignSystem.error, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.close_rounded, size: 16),
                    const SizedBox(width: TossDesignSystem.spacing4),
                    Text(
                      '거절',
                      style: TossDesignSystem.button.copyWith(
                        color: TossDesignSystem.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: TossDesignSystem.spacing12),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    () => controller.updateOrderStatus(
                      order.id,
                      OrderStatus.confirmed,
                    ),
                style: TossDesignSystem.primaryButton,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 16),
                    const SizedBox(width: TossDesignSystem.spacing4),
                    Text(
                      '승인',
                      style: TossDesignSystem.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                () => controller.updateOrderStatus(
                  order.id,
                  OrderStatus.completed,
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: TossDesignSystem.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: TossDesignSystem.spacing16,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_shipping_rounded, size: 16),
                const SizedBox(width: TossDesignSystem.spacing8),
                Text(
                  '배송완료',
                  style: TossDesignSystem.button.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        );

      case OrderStatus.completed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: TossDesignSystem.spacing12,
          ),
          decoration: BoxDecoration(
            color: TossDesignSystem.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_shipping_rounded,
                color: TossDesignSystem.success,
                size: 16,
              ),
              const SizedBox(width: TossDesignSystem.spacing8),
              Text(
                '배송완료',
                style: TossDesignSystem.body2.copyWith(
                  color: TossDesignSystem.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case OrderStatus.cancelled:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: TossDesignSystem.spacing12,
          ),
          decoration: BoxDecoration(
            color: TossDesignSystem.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cancel_rounded,
                color: TossDesignSystem.error,
                size: 16,
              ),
              const SizedBox(width: TossDesignSystem.spacing8),
              Text(
                '거절됨',
                style: TossDesignSystem.body2.copyWith(
                  color: TossDesignSystem.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }
  }

  /// 거절 확인 다이얼로그
  void _showRejectDialog(OrderModel order) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TossDesignSystem.radius20),
        ),
        backgroundColor: TossDesignSystem.surface,
        child: Padding(
          padding: const EdgeInsets.all(TossDesignSystem.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: TossDesignSystem.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    TossDesignSystem.radius16,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 32,
                  color: TossDesignSystem.error,
                ),
              ),
              const SizedBox(height: TossDesignSystem.spacing20),
              Text(
                '주문을 거절하시겠어요?',
                style: TossDesignSystem.heading4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossDesignSystem.spacing8),
              Text(
                '${order.buyerBusinessName ?? order.buyerName}의 주문\n거절된 주문은 되돌릴 수 없어요',
                style: TossDesignSystem.body2.copyWith(
                  color: TossDesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossDesignSystem.spacing32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: TossDesignSystem.outlineButton,
                      child: Text(
                        '취소',
                        style: TossDesignSystem.button.copyWith(
                          color: TossDesignSystem.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TossDesignSystem.spacing12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateOrderStatus(
                          order.id,
                          OrderStatus.cancelled,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TossDesignSystem.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TossDesignSystem.radius12,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TossDesignSystem.spacing20,
                          vertical: TossDesignSystem.spacing16,
                        ),
                      ),
                      child: Text(
                        '거절',
                        style: TossDesignSystem.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '신규';
      case OrderStatus.confirmed:
        return '주문확인';
      case OrderStatus.completed:
        return '배송완료';
      case OrderStatus.cancelled:
        return '거절';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return TossDesignSystem.warning;
      case OrderStatus.confirmed:
        return TossDesignSystem.info;
      case OrderStatus.completed:
        return TossDesignSystem.success;
      case OrderStatus.cancelled:
        return TossDesignSystem.error;
    }
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 필터 바텀시트 표시
  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: TossDesignSystem.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(TossDesignSystem.radius20),
            topRight: Radius.circular(TossDesignSystem.radius20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.only(top: TossDesignSystem.spacing12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TossDesignSystem.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 헤더
            Padding(
              padding: const EdgeInsets.all(TossDesignSystem.spacing20),
              child: Row(
                children: [
                  Text('기간 선택', style: TossDesignSystem.heading4),
                  const Spacer(),
                  TossWidgets.iconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Get.back(),
                    backgroundColor: TossDesignSystem.gray100,
                    size: 32,
                  ),
                ],
              ),
            ),

            // 빠른 필터 옵션들
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TossDesignSystem.spacing20,
              ),
              child: Column(
                children: [
                  _buildFilterOption(DateFilterType.today),
                  const SizedBox(height: TossDesignSystem.spacing8),
                  _buildFilterOption(DateFilterType.week),
                  const SizedBox(height: TossDesignSystem.spacing8),
                  _buildFilterOption(DateFilterType.month),
                  const SizedBox(height: TossDesignSystem.spacing8),
                  _buildFilterOption(DateFilterType.threeMonths),
                  const SizedBox(height: TossDesignSystem.spacing16),

                  // 구분선
                  Container(height: 1, color: TossDesignSystem.gray200),
                  const SizedBox(height: TossDesignSystem.spacing16),

                  // 기간 직접 선택
                  _buildCustomDateOption(),
                ],
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacing20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// 필터 옵션 위젯
  Widget _buildFilterOption(DateFilterType filterType) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          controller.setFilter(filterType);
          Get.back();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TossDesignSystem.spacing16),
          decoration: BoxDecoration(
            color:
                controller.currentFilter.value == filterType
                    ? TossDesignSystem.primary.withOpacity(0.1)
                    : TossDesignSystem.gray50,
            borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
            border: Border.all(
              color:
                  controller.currentFilter.value == filterType
                      ? TossDesignSystem.primary
                      : TossDesignSystem.gray200,
              width: controller.currentFilter.value == filterType ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getFilterIcon(filterType),
                color:
                    controller.currentFilter.value == filterType
                        ? TossDesignSystem.primary
                        : TossDesignSystem.textSecondary,
                size: 20,
              ),
              const SizedBox(width: TossDesignSystem.spacing12),
              Text(
                filterType.displayText,
                style: TossDesignSystem.body1.copyWith(
                  color:
                      controller.currentFilter.value == filterType
                          ? TossDesignSystem.primary
                          : TossDesignSystem.textPrimary,
                  fontWeight:
                      controller.currentFilter.value == filterType
                          ? FontWeight.w600
                          : FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (controller.currentFilter.value == filterType)
                const Icon(
                  Icons.check_rounded,
                  color: TossDesignSystem.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 커스텀 날짜 선택 옵션
  Widget _buildCustomDateOption() {
    return GestureDetector(
      onTap: _showDateRangePicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TossDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: TossDesignSystem.gray50,
          borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
          border: Border.all(color: TossDesignSystem.gray200, width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.date_range_rounded,
              color: TossDesignSystem.textSecondary,
              size: 20,
            ),
            const SizedBox(width: TossDesignSystem.spacing12),
            Text(
              '기간 직접 선택',
              style: TossDesignSystem.body1.copyWith(
                color: TossDesignSystem.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: TossDesignSystem.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜 범위 선택기 표시 (토스 캘린더 사용)
  void _showDateRangePicker() async {
    Get.back(); // 바텀시트 닫기

    // 토스 스타일 캘린더 다이얼로그 표시
    await showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(TossDesignSystem.spacing20),
            child: TossCalendarWidget(
              initialStartDate: controller.customStartDate.value,
              initialEndDate: controller.customEndDate.value,
              isRangeSelection: true,
              onDateRangeSelected: (startDate, endDate) {
                if (startDate != null && endDate != null) {
                  controller.setCustomDateRange(startDate, endDate);
                }
              },
            ),
          ),
    );
  }

  /// 필터 타입별 아이콘 반환
  IconData _getFilterIcon(DateFilterType filterType) {
    switch (filterType) {
      case DateFilterType.today:
        return Icons.today_rounded;
      case DateFilterType.week:
        return Icons.view_week_rounded;
      case DateFilterType.month:
        return Icons.calendar_month_rounded;
      case DateFilterType.threeMonths:
        return Icons.calendar_view_month_rounded;
      case DateFilterType.custom:
        return Icons.date_range_rounded;
    }
  }
}
