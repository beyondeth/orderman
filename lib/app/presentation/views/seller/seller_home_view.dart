import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/toss_design_system.dart';
import '../../controllers/seller/seller_home_controller.dart';

class SellerHomeView extends GetView<SellerHomeController> {
  const SellerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러가 등록되지 않은 경우 등록
    if (!Get.isRegistered<SellerHomeController>()) {
      Get.put(SellerHomeController());
    }
    
    return Scaffold(
      backgroundColor: TossDesignSystem.background,
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: TossDesignSystem.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TossDesignSystem.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영 섹션 (구매자 스타일 적용)
              _buildWelcomeSection(context),
              const SizedBox(height: TossDesignSystem.spacing32),
              
              // 오늘의 매출 요약
              _buildTodaySummaryCard(context),
              const SizedBox(height: TossDesignSystem.spacing24),
              
              // 주문 현황 카드들
              _buildOrderStatusCards(context),
              const SizedBox(height: TossDesignSystem.spacing24),
              
              // 최근 주문 목록
              _buildRecentOrdersList(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 환영 섹션 (구매자 스타일 적용)
  Widget _buildWelcomeSection(BuildContext context) {
    return Obx(() {
      final user = controller.currentUser;
      final userName = user?.displayName ?? '판매자';
      final businessName = user?.businessName;
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TossDesignSystem.spacing24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [TossDesignSystem.primary, TossDesignSystem.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(TossDesignSystem.radius20),
          boxShadow: [
            BoxShadow(
              color: TossDesignSystem.primary.withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(TossDesignSystem.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
                  ),
                  child: const Icon(
                    Icons.store_rounded, // 판매자용 아이콘
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: TossDesignSystem.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 사업체명이 있으면 먼저 표시
                      if (businessName != null && businessName.isNotEmpty) ...[
                        Text(
                          businessName,
                          style: TossDesignSystem.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: TossDesignSystem.spacing4),
                        Text(
                          userName,
                          style: TossDesignSystem.body1.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        // 사업체명이 없으면 이름만 표시
                        Text(
                          userName,
                          style: TossDesignSystem.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: TossDesignSystem.spacing8),
                      Text(
                        '오늘도 좋은 하루 되세요!',
                        style: TossDesignSystem.body2.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 설정 버튼을 오른쪽에 배치
                TossWidgets.iconButton(
                  icon: Icons.settings_outlined,
                  onPressed: controller.goToSettings,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  iconColor: Colors.white,
                  size: 40,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// 오늘의 매출 요약 카드
  Widget _buildTodaySummaryCard(BuildContext context) {
    return TossWidgets.card(
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
                  borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: TossDesignSystem.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: TossDesignSystem.spacing12),
              Text(
                '오늘의 매출',
                style: TossDesignSystem.heading4,
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacing20),
          
          Obx(() => Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '총 주문',
                      style: TossDesignSystem.body2.copyWith(
                        color: TossDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: TossDesignSystem.spacing4),
                    Text(
                      '${controller.totalOrdersToday.value}건',
                      style: TossDesignSystem.heading3.copyWith(
                        color: TossDesignSystem.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: TossDesignSystem.gray200,
              ),
              const SizedBox(width: TossDesignSystem.spacing20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '총 매출',
                      style: TossDesignSystem.body2.copyWith(
                        color: TossDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: TossDesignSystem.spacing4),
                    Text(
                      '${controller.formatAmount(controller.totalAmountToday.value)}원',
                      style: TossDesignSystem.heading3.copyWith(
                        color: TossDesignSystem.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  /// 주문 현황 카드들
  Widget _buildOrderStatusCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주문 현황',
          style: TossDesignSystem.heading4,
        ),
        const SizedBox(height: TossDesignSystem.spacing16),
        
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatusCard(
                '신규 주문',
                controller.pendingOrdersCount.value,
                TossDesignSystem.warning,
                Icons.fiber_new_rounded,
              )),
            ),
            const SizedBox(width: TossDesignSystem.spacing12),
            Expanded(
              child: Obx(() => _buildStatusCard(
                '처리 중',
                controller.approvedOrdersCount.value,
                TossDesignSystem.info,
                Icons.schedule_rounded,
              )),
            ),
            const SizedBox(width: TossDesignSystem.spacing12),
            Expanded(
              child: Obx(() => _buildStatusCard(
                '완료',
                controller.completedOrdersCount.value,
                TossDesignSystem.success,
                Icons.check_circle_rounded,
              )),
            ),
          ],
        ),
      ],
    );
  }

  /// 개별 상태 카드
  Widget _buildStatusCard(String title, int count, Color color, IconData icon) {
    return TossWidgets.surfaceCard(
      padding: const EdgeInsets.all(TossDesignSystem.spacing16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacing12),
          Text(
            count.toString(),
            style: TossDesignSystem.heading3.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacing4),
          Text(
            title,
            style: TossDesignSystem.caption.copyWith(
              color: TossDesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 최근 주문 목록
  Widget _buildRecentOrdersList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 주문',
              style: TossDesignSystem.heading4,
            ),
            TextButton(
              onPressed: controller.goToOrderManagement,
              style: TextButton.styleFrom(
                foregroundColor: TossDesignSystem.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: TossDesignSystem.spacing12,
                  vertical: TossDesignSystem.spacing8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체보기',
                    style: TossDesignSystem.body2.copyWith(
                      color: TossDesignSystem.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: TossDesignSystem.spacing4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: TossDesignSystem.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: TossDesignSystem.spacing16),
        
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(TossDesignSystem.spacing40),
                child: CircularProgressIndicator(
                  color: TossDesignSystem.primary,
                ),
              ),
            );
          }

          if (controller.todayOrders.isEmpty) {
            return _buildEmptyOrdersState();
          }

          // 최대 5개만 표시
          final recentOrders = controller.todayOrders.take(5).toList();
          
          return Column(
            children: recentOrders.map((order) => 
              Padding(
                padding: const EdgeInsets.only(bottom: TossDesignSystem.spacing12),
                child: _buildOrderItem(order),
              )
            ).toList(),
          );
        }),
      ],
    );
  }

  /// 빈 주문 상태
  Widget _buildEmptyOrdersState() {
    return TossWidgets.surfaceCard(
      padding: const EdgeInsets.all(TossDesignSystem.spacing32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(TossDesignSystem.radius16),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 32,
              color: TossDesignSystem.gray400,
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacing16),
          Text(
            '오늘 들어온 주문이 없어요',
            style: TossDesignSystem.body1.copyWith(
              color: TossDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacing8),
          Text(
            '새로운 주문이 들어오면 알려드릴게요',
            style: TossDesignSystem.caption.copyWith(
              color: TossDesignSystem.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 주문 아이템
  Widget _buildOrderItem(dynamic order) {
    return TossWidgets.card(
      onTap: () => controller.goToOrderDetail(order),
      padding: const EdgeInsets.all(TossDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      DateFormat('HH:mm').format(order.orderDate),
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
                    '${controller.formatAmount(order.totalAmount)}원',
                    style: TossDesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TossDesignSystem.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacing12),
          
          // 주문 상품 요약
          Container(
            padding: const EdgeInsets.all(TossDesignSystem.spacing12),
            decoration: BoxDecoration(
              color: TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: TossDesignSystem.textSecondary,
                ),
                const SizedBox(width: TossDesignSystem.spacing8),
                Expanded(
                  child: Text(
                    '${order.items.first.productName}${order.items.length > 1 ? ' 외 ${order.items.length - 1}개' : ''}',
                    style: TossDesignSystem.caption.copyWith(
                      color: TossDesignSystem.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '총 ${order.items.length}개 상품',
                  style: TossDesignSystem.caption.copyWith(
                    color: TossDesignSystem.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(dynamic status) {
    switch (status.toString()) {
      case 'OrderStatus.pending':
        return '신규';
      case 'OrderStatus.confirmed':
        return '처리중';
      case 'OrderStatus.completed':
        return '완료';
      case 'OrderStatus.cancelled':
        return '거절';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'OrderStatus.pending':
        return TossDesignSystem.warning;
      case 'OrderStatus.confirmed':
        return TossDesignSystem.info;
      case 'OrderStatus.completed':
        return TossDesignSystem.success;
      case 'OrderStatus.cancelled':
        return TossDesignSystem.error;
      default:
        return TossDesignSystem.gray500;
    }
  }
}
