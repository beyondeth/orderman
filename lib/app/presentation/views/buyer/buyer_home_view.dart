import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/layout/app_layout.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/utils/order_utils.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/connection_model.dart';
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/main_controller.dart';

class BuyerHomeView extends GetView<BuyerHomeController> {
  const BuyerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러가 등록되지 않은 경우 등록
    if (!Get.isRegistered<BuyerHomeController>()) {
      Get.put(BuyerHomeController());
    }
    
    return RefreshIndicator(
      onRefresh: controller.refreshConnections,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // 중요: 최소 크기로 제한
                children: [
                  // 인사말 및 사용자 정보
                  _buildWelcomeSection(context).responsiveSection(
                    margin: EdgeInsets.only(bottom: AppLayout.getSpacing(context)),
                  ),

                  // 최근 주문 내역
                  _buildRecentOrders(context).responsiveSection(
                    title: '최근 주문 내역',
                    showDivider: true,
                    margin: EdgeInsets.only(bottom: AppLayout.getSpacing(context)),
                  ),

                  // 연결된 판매자 목록
                  _buildConnectedSellers(context).responsiveSection(
                    title: '연결된 판매자',
                    showDivider: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AuthService의 사용자 정보 변경을 감지하여 실시간 업데이트
                    GetX<AuthService>(
                      builder: (authService) {
                        final hour = DateTime.now().hour;
                        String greeting;
                        if (hour < 12) {
                          greeting = '좋은 아침입니다!';
                        } else if (hour < 18) {
                          greeting = '좋은 오후입니다!';
                        } else {
                          greeting = '좋은 저녁입니다!';
                        }
                        
                        return Text(
                          greeting,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                    AppSpacing.verticalGapXS,
                    // 사용자 이름도 AuthService에서 직접 가져오기
                    GetX<AuthService>(
                      builder: (authService) {
                        final userName = authService.userModel?.displayName ?? '구매자';
                        return Text(
                          '${userName}님',
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    // 비즈니스 이름도 마찬가지
                    GetX<AuthService>(
                      builder: (authService) {
                        final businessName = authService.userModel?.businessName ?? '';
                        if (businessName.isEmpty) return const SizedBox.shrink();
                        
                        return Column(
                          children: [
                            AppSpacing.verticalGapXS,
                            Text(
                              businessName,
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (AppLayout.isTabletOrLarger(context))
                Container(
                  padding: AppSpacing.paddingLG,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    return Obx(() {
      try {
        if (controller.isLoadingOrders.value) {
          return AppComponents.loadingIndicator(message: '주문 내역을 불러오는 중...');
        }

        if (controller.recentOrders.isEmpty) {
          return AppComponents.emptyState(
            title: '최근 주문이 없습니다',
            subtitle: '첫 주문을 시작해보세요!',
            icon: Icons.shopping_bag_outlined,
            action: AppComponents.primaryButton(
              text: '주문하기',
              onPressed: _navigateToOrders,
              icon: Icons.add_shopping_cart,
            ),
          );
        }

        final displayOrders = controller.recentOrders.take(3).toList();
        
        return Column(
          children: [
            ...displayOrders.map((order) => _buildOrderCard(context, order)),
            if (controller.recentOrders.length > 3) ...[
              AppSpacing.verticalGapMD,
              AppComponents.textButton(
                text: '전체보기 (${controller.recentOrders.length}개)',
                onPressed: _navigateToHistory,
                icon: Icons.arrow_forward,
              ),
            ],
          ],
        );
      } catch (e) {
        print('_buildRecentOrders 오류: $e');
        return AppComponents.emptyState(
          title: '주문 내역을 불러올 수 없습니다',
          subtitle: '잠시 후 다시 시도해주세요',
          icon: Icons.error_outline,
          action: AppComponents.primaryButton(
            text: '새로고침',
            onPressed: () => controller.refreshConnections(),
            icon: Icons.refresh,
          ),
        );
      }
    });
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return ResponsiveCard(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '주문 #${order.id.substring(0, 8)}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalGapXS,
                    Text(
                      OrderUtils.formatDate(order.createdAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: AppSpacing.paddingSM,
                decoration: BoxDecoration(
                  color: OrderUtils.getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      OrderUtils.getStatusIcon(order.status),
                      size: 16,
                      color: OrderUtils.getStatusColor(order.status),
                    ),
                    AppSpacing.horizontalGapXS,
                    Text(
                      OrderUtils.getStatusText(order.status),
                      style: AppTypography.bodySmall.copyWith(
                        color: OrderUtils.getStatusColor(order.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapSM,
          Text(
            '총 ${order.items.length}개 상품',
            style: AppTypography.bodyMedium,
          ),
          if (order.totalAmount > 0) ...[
            AppSpacing.verticalGapXS,
            Text(
              OrderUtils.formatCurrency(order.totalAmount),
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectedSellers(BuildContext context) {
    return Obx(() {
      try {
        if (controller.isLoadingConnections.value) {
          return AppComponents.loadingIndicator(message: '연결된 판매자를 불러오는 중...');
        }

        if (controller.connections.isEmpty) {
          return AppComponents.emptyState(
            title: '연결된 판매자가 없습니다',
            subtitle: '판매자와 연결하여 주문을 시작하세요',
            icon: Icons.link_off,
            action: AppComponents.primaryButton(
              text: '판매자 연결하기',
              onPressed: _navigateToConnect,
              icon: Icons.add_link,
            ),
          );
        }

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: controller.connections.map((connection) => 
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 600 
                    ? (MediaQuery.of(context).size.width - 48) / 2 
                    : double.infinity,
                minHeight: 120,
              ),
              child: _buildSellerCard(context, connection),
            )
          ).toList(),
        );
      } catch (e) {
        print('_buildConnectedSellers 오류: $e');
        return AppComponents.emptyState(
          title: '판매자 목록을 불러올 수 없습니다',
          subtitle: '잠시 후 다시 시도해주세요',
          icon: Icons.error_outline,
          action: AppComponents.primaryButton(
            text: '새로고침',
            onPressed: () => controller.refreshConnections(),
            icon: Icons.refresh,
          ),
        );
      }
    });
  }

  Widget _buildSellerCard(BuildContext context, ConnectionModel connection) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      connection.sellerName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (connection.sellerEmail != null) ...[
                      AppSpacing.verticalGapXS,
                      Text(
                        connection.sellerEmail!,
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showSellerActions(context, connection),
                icon: const Icon(Icons.more_vert),
                tooltip: '더보기',
              ),
            ],
          ),
          AppSpacing.verticalGapMD,
          Row(
            children: [
              Expanded(
                child: AppComponents.primaryButton(
                  text: '주문하기',
                  onPressed: () => _orderFromSeller(connection),
                  icon: Icons.shopping_cart,
                ),
              ),
              AppSpacing.horizontalGapSM,
              AppComponents.outlinedButton(
                text: '채팅',
                onPressed: () => _chatWithSeller(connection),
                icon: Icons.chat_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 네비게이션 메서드들
  void _navigateToOrders() {
    Get.find<MainController>().changeTabIndex(1);
  }

  void _navigateToHistory() {
    Get.find<MainController>().changeTabIndex(2);
  }

  void _navigateToConnect() {
    Get.find<MainController>().changeTabIndex(3);
  }

  void _showSellerActions(BuildContext context, ConnectionModel connection) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('주문하기'),
              onTap: () {
                Navigator.pop(context);
                _orderFromSeller(connection);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('채팅하기'),
              onTap: () {
                Navigator.pop(context);
                _chatWithSeller(connection);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('판매자 정보'),
              onTap: () {
                Navigator.pop(context);
                _showSellerInfo(connection);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _orderFromSeller(ConnectionModel connection) {
    // 해당 판매자로부터 주문하기
    Get.find<MainController>().setActiveConnection(connection);
    _navigateToOrders();
  }

  void _chatWithSeller(ConnectionModel connection) {
    // 판매자와 채팅하기
    Get.snackbar('채팅', '${connection.sellerName}과의 채팅 기능은 준비 중입니다.');
  }

  void _showSellerInfo(ConnectionModel connection) {
    // 판매자 정보 보기
    Get.dialog(
      AlertDialog(
        title: Text(connection.sellerName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (connection.sellerEmail != null)
              Text('이메일: ${connection.sellerEmail}'),
            AppSpacing.verticalGapSM,
            Text('연결일: ${OrderUtils.formatDate(connection.requestedAt)}'),
            AppSpacing.verticalGapSM,
            Text('상태: ${connection.status}'),
          ],
        ),
        actions: [
          AppComponents.textButton(
            text: '닫기',
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
