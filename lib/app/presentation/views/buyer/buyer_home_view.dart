import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/order_utils.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/buyer/seller_connect_controller.dart';
import '../../controllers/buyer/order_history_controller.dart';
import '../../controllers/main_controller.dart';

class BuyerHomeView extends GetView<BuyerHomeController> {
  const BuyerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러가 등록되지 않은 경우 등록
    if (!Get.isRegistered<BuyerHomeController>()) {
      Get.put(BuyerHomeController());
    }

    // 연결 탭과 내역 탭의 컨트롤러도 필요시 등록
    if (!Get.isRegistered<SellerConnectController>()) {
      Get.lazyPut(() => SellerConnectController());
    }
    if (!Get.isRegistered<OrderHistoryController>()) {
      Get.lazyPut(() => OrderHistoryController());
    }

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 환영 섹션
            _buildWelcomeSection(context),
            const SizedBox(height: AppConstants.largePadding * 2),

            // 연결된 판매자 섹션 (연결 탭의 UI/UX 재사용)
            _buildConnectedSellersSection(context),
            const SizedBox(height: AppConstants.largePadding * 2),

            // 최근 주문 섹션 (내역 탭의 UI/UX 재사용)
            _buildRecentOrdersSection(context),
          ],
        ),
      ),
    );
  }

  /// 환영 메시지 섹션
  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요! 👋',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '신선한 식자재를 주문해보세요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 연결된 판매자 섹션 (seller_connect_view.dart의 _buildConnectedSellersSection 재사용)
  Widget _buildConnectedSellersSection(BuildContext context) {
    // SellerConnectController 사용하여 기존 로직 재사용
    final connectController = Get.find<SellerConnectController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더 (연결 탭과 동일한 스타일)
        Row(
          children: [
            Icon(Icons.people, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '연결된 판매자',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // 더보기 버튼 추가
            TextButton(
              onPressed: () {
                final mainController = Get.find<MainController>();
                mainController.changeTab(3); // 연결 탭으로 이동
              },
              child: Text(
                '더보기',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // 연결된 판매자 목록 (연결 탭과 동일한 로직)
        Obx(() {
          if (connectController.isLoadingConnections.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.largePadding),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (connectController.connectedSellers.isEmpty) {
            return _buildEmptyConnectedSellersState(context);
          }

          // 최대 3개만 표시 (홈 화면이므로)
          final displaySellers = connectController.connectedSellers.take(3).toList();
          
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displaySellers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final connection = displaySellers[index];
              return _buildSellerCard(context, connection);
            },
          );
        }),
      ],
    );
  }

  /// 빈 연결 상태 (연결 탭과 동일한 스타일)
  Widget _buildEmptyConnectedSellersState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '연결된 판매자가 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '연결 탭에서 판매자와 연결해보세요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final mainController = Get.find<MainController>();
                mainController.changeTab(3); // 연결 탭으로 이동
              },
              child: const Text('판매자 연결하기'),
            ),
          ],
        ),
      ),
    );
  }

  /// 판매자 카드 (연결 탭과 동일한 스타일)
  Widget _buildSellerCard(BuildContext context, dynamic connection) {
    final connectController = Get.find<SellerConnectController>();
    
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.store, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          connection.sellerName ?? '판매자',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(connection.sellerEmail ?? ''),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '연결됨',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => connectController.goToOrder(connection),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('주문하기'),
        ),
        isThreeLine: true,
      ),
    );
  }

  /// 최근 주문 섹션 (order_history_view.dart의 _buildOrderList 재사용)
  Widget _buildRecentOrdersSection(BuildContext context) {
    // OrderHistoryController 사용하여 기존 로직 재사용
    final historyController = Get.find<OrderHistoryController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더 (내역 탭과 동일한 스타일)
        Row(
          children: [
            Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '최근 주문',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // 더보기 버튼 추가
            TextButton(
              onPressed: () {
                final mainController = Get.find<MainController>();
                mainController.changeTab(2); // 내역 탭으로 이동
              },
              child: Text(
                '더보기',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // 최근 주문 목록 (내역 탭과 동일한 로직)
        Obx(() {
          if (historyController.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.largePadding),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (historyController.orders.isEmpty) {
            return _buildEmptyOrdersState(context);
          }

          // 최대 3개만 표시 (홈 화면이므로)
          final recentOrders = historyController.orders.take(3).toList();
          
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppConstants.smallPadding),
            itemBuilder: (context, index) {
              final order = recentOrders[index];
              return _buildOrderItem(context, order);
            },
          );
        }),
      ],
    );
  }

  /// 빈 주문 상태 (내역 탭과 동일한 스타일)
  Widget _buildEmptyOrdersState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
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
                color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              '첫 주문을 시작해보세요!',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final mainController = Get.find<MainController>();
                mainController.changeTab(1); // 주문 탭으로 이동
              },
              child: const Text('주문하러 가기'),
            ),
          ],
        ),
      ),
    );
  }

  /// 주문 아이템 (내역 탭과 완전히 동일한 ExpansionTile 형태)
  Widget _buildOrderItem(BuildContext context, OrderModel order) {
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
                    color: order.status.color.withValues(alpha: 0.2),
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
        // 내역 탭과 완전히 동일한 확장 내용
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
                // 주문 상품 목록 (내역 탭과 동일)
                ...order.items.map(
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
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                // 구분선
                const Divider(),
                const SizedBox(height: AppConstants.smallPadding),
                // 총 금액 (내역 탭과 동일)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 금액',
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${order.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: Get.theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
