import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/order_utils.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/main_controller.dart';

class BuyerHomeViewRefactored extends GetView<BuyerHomeController> {
  const BuyerHomeViewRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshConnections,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인사말 및 사용자 정보
            _buildWelcomeSection(context),
            AppSpacing.verticalGapLG,

            // 최근 주문 내역 섹션
            _buildRecentOrdersSection(context),
            AppSpacing.verticalGapLG,

            // 연결된 판매자 목록
            _buildConnectedSellersSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return AppComponents.appCard(
      padding: AppSpacing.paddingLG,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.greetingMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            AppSpacing.verticalGapXS,

            Text(
              '${controller.userName}님',
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (controller.businessName.isNotEmpty) ...[
              AppSpacing.verticalGapXS,
              Text(
                controller.businessName,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],

            AppSpacing.verticalGapMD,

            Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                AppSpacing.horizontalGapSM,
                Expanded(
                  child: Text(
                    '오늘도 효율적인 주문 관리를 시작해보세요',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersSection(BuildContext context) {
    return Column(
      children: [
        AppComponents.sectionHeader(
          title: '최근 주문 내역',
          trailing: AppComponents.textButton(
            text: '전체보기',
            onPressed: () {
              // 내역 탭으로 이동
              final mainController = Get.find<MainController>();
              mainController.changeTabIndex(2); // 내역 탭 인덱스
            },
            icon: Icons.arrow_forward_ios,
          ),
        ),

        AppSpacing.verticalGapSM,

        Obx(() {
          if (controller.isLoadingOrders.value) {
            return AppComponents.loadingIndicator(message: '주문 내역을 불러오는 중...');
          }

          if (controller.recentOrders.isEmpty) {
            return AppComponents.emptyState(
              title: '최근 주문 내역이 없습니다',
              subtitle: '연결된 판매자에게 주문을 해보세요',
              icon: Icons.receipt_long_outlined,
              action: AppComponents.secondaryButton(
                text: '주문하기',
                onPressed: () {
                  final mainController = Get.find<MainController>();
                  mainController.changeTabIndex(1); // 주문 탭으로 이동
                },
                icon: Icons.shopping_cart,
              ),
            );
          }

          return Column(
            children:
                controller.recentOrders
                    .take(3) // 최근 3개만 표시
                    .map((order) => _buildOrderCard(context, order))
                    .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return AppComponents.appCard(
      margin: AppSpacing.verticalSM,
      onTap: () {
        // 주문 상세 화면으로 이동
        // Get.toNamed('/order-detail', arguments: order.id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주문 #${order.id.substring(0, 8)}',
                style: AppTypography.titleMedium,
              ),
              AppComponents.statusChip(
                label: OrderUtils.getStatusText(order.status as String),
                color: OrderUtils.getStatusColor(order.status as String),
                icon: OrderUtils.getStatusIcon(order.status as String),
              ),
            ],
          ),

          AppSpacing.verticalGapSM,

          Text(
            '판매자: ${order.sellerName}',
            style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
          ),

          AppSpacing.verticalGapXS,

          Text(
            '주문일: ${OrderUtils.formatDate(order.createdAt)}',
            style: AppTypography.bodySmall.copyWith(color: Colors.grey[500]),
          ),

          if (order.totalAmount > 0) ...[
            AppSpacing.verticalGapXS,
            Text(
              '총 금액: ${OrderUtils.formatCurrency(order.totalAmount)}',
              style: AppTypography.price,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectedSellersSection(BuildContext context) {
    return Column(
      children: [
        AppComponents.sectionHeader(
          title: '연결된 판매자',
          subtitle: '${controller.connectedSellers.length}명의 판매자와 연결됨',
          trailing: AppComponents.textButton(
            text: '연결 관리',
            onPressed: () {
              final mainController = Get.find<MainController>();
              mainController.changeTabIndex(3); // 연결 탭으로 이동
            },
            icon: Icons.settings,
          ),
        ),

        AppSpacing.verticalGapSM,

        Obx(() {
          if (controller.isLoadingConnections.value) {
            return AppComponents.loadingIndicator(
              message: '연결된 판매자를 불러오는 중...',
            );
          }

          if (controller.connectedSellers.isEmpty) {
            return AppComponents.emptyState(
              title: '연결된 판매자가 없습니다',
              subtitle: '판매자와 연결하여 주문을 시작해보세요',
              icon: Icons.link_off,
              action: AppComponents.primaryButton(
                text: '판매자 연결하기',
                onPressed: () {
                  final mainController = Get.find<MainController>();
                  mainController.changeTabIndex(3); // 연결 탭으로 이동
                },
                icon: Icons.add_link,
              ),
            );
          }

          return Column(
            children:
                controller.connectedSellers
                    .map((seller) => _buildSellerCard(context, seller))
                    .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSellerCard(BuildContext context, dynamic seller) {
    return AppComponents.appCard(
      margin: AppSpacing.verticalSM,
      onTap: () {
        // 판매자 상세 또는 주문 화면으로 이동
        final mainController = Get.find<MainController>();
        mainController.changeTabIndex(1); // 주문 탭으로 이동
      },
      child: Row(
        children: [
          // 판매자 아바타
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
            child: Icon(
              Icons.store,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),

          AppSpacing.horizontalGapMD,

          // 판매자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller['businessName'] ?? '판매자',
                  style: AppTypography.titleMedium,
                ),
                AppSpacing.verticalGapXS,
                Text(
                  seller['email'] ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (seller['lastOrderDate'] != null) ...[
                  AppSpacing.verticalGapXS,
                  Text(
                    '최근 주문: ${OrderUtils.formatDate(seller['lastOrderDate'])}',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 주문하기 버튼
          AppComponents.secondaryButton(
            text: '주문하기',
            onPressed: () {
              // 해당 판매자 주문 화면으로 이동
              final mainController = Get.find<MainController>();
              mainController.changeTabIndex(1);
            },
            icon: Icons.shopping_cart_outlined,
          ),
        ],
      ),
    );
  }
}
