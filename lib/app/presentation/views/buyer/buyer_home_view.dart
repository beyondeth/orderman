import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_market_app/app/presentation/controllers/buyer/order_history_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/order_utils.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart'; // UserState 사용을 위해 추가
import '../../../core/services/auth_service.dart'; // AuthService 사용을 위해 추가
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/buyer/seller_connect_controller.dart';
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
            const SizedBox(height: AppConstants.defaultPadding),

            // 최근 주문 섹션 (내역 탭의 UI/UX 재사용)
            _buildRecentOrdersSection(context),
          ],
        ),
      ),
    );
  }

  /// 환영 메시지 섹션 - 개선된 버전
  Widget _buildWelcomeSection(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Obx(() {
      final userState = authService.userStateRx.value;
      String userName = '구매자';
      String? businessName;
      String welcomeMessage = '신선한 식자재를 주문해보세요';
      Widget content;

      if (userState is UserLoading) {
        content = const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
        welcomeMessage = '사용자 정보를 불러오는 중...';
      } else if (userState is UserLoaded) {
        final user = (userState as UserLoaded).user;
        userName = user.displayName;
        businessName = user.businessName;
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (businessName != null && businessName.isNotEmpty) ...[
              Text(
                businessName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              welcomeMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        );
      } else if (userState is UserError) {
        userName = '사용자';
        welcomeMessage =
            '사용자 정보를 불러오지 못했습니다: ${(userState as UserError).message}';
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오류 발생',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              welcomeMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // 재시도 로직 (AuthService에서 다시 로드 시도)
                if (authService.firebaseUser != null) {
                  authService.loadUserData(authService.firebaseUser!.uid);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
              child: const Text('재시도'),
            ),
          ],
        );
      } else {
        // UserInitial, UserNew 또는 알 수 없는 상태
        userName = '구매자';
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              welcomeMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        );
      }

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
              color: AppColors.primary.withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.medium),
            Expanded(child: content),
          ],
        ),
      );
    });
  }

  /// 연결된 판매자 섹션 - 개선된 버전 (중복 헤더 제거)
  Widget _buildConnectedSellersSection(BuildContext context) {
    // SellerConnectController 사용하여 기존 로직 재사용
    final connectController = Get.find<SellerConnectController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 내부 헤더 (내역 탭과 동일한 스타일)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '연결된 판매자',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final mainController = Get.find<MainController>();
                    mainController.changeTab(3); // 연결 탭으로 이동
                  },
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 연결된 판매자 목록
          Obx(() {
            if (connectController.isLoadingConnections.value) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (connectController.connectedSellers.isEmpty) {
              return _buildEmptyConnectedSellersState(context);
            }

            // 최대 3개만 표시 (홈 화면이므로)
            final displaySellers =
                connectController.connectedSellers.take(3).toList();

            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displaySellers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final connection = displaySellers[index];
                  return _buildSellerCard(context, connection);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 빈 연결 상태 - 개선된 버전
  Widget _buildEmptyConnectedSellersState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.store_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            '연결된 판매자가 없습니다',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '연결 탭에서 판매자와 연결해보세요',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final mainController = Get.find<MainController>();
              mainController.changeTab(3); // 연결 탭으로 이동
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('판매자 연결하기'),
          ),
        ],
      ),
    );
  }

  /// 판매자 카드 - 아이콘 제거된 버전 (텍스트만 유지)
  Widget _buildSellerCard(BuildContext context, dynamic connection) {
    final connectController = Get.find<SellerConnectController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 판매자명, 판매자, 연결됨을 가로로 나란히 배치 (아이콘 없이)
            Expanded(
              child: Row(
                children: [
                  // 판매자명
                  Text(
                    connection.sellerName ?? '판매자',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 판매자 텍스트 (아이콘 삭제)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '판매자',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 연결됨 텍스트 (아이콘 삭제)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '연결됨',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 오른쪽: 주문하기 버튼
            ElevatedButton(
              onPressed: () => connectController.goToOrder(connection),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: const Size(60, 32),
              ),
              child: const Text('주문하기', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  /// 최근 주문 섹션 - 개선된 버전 (중복 헤더 제거, 클릭 시 내역 탭 이동)
  Widget _buildRecentOrdersSection(BuildContext context) {
    // OrderHistoryController 사용하여 기존 로직 재사용
    final historyController = Get.find<OrderHistoryController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 내부 헤더 (연결된 판매자와 동일한 스타일)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '최근 주문',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final mainController = Get.find<MainController>();
                    mainController.changeTab(2); // 내역 탭으로 이동
                  },
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 최근 주문 목록
          Obx(() {
            if (historyController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (historyController.orders.isEmpty) {
              return _buildEmptyOrdersState(context);
            }

            // 최대 3개만 표시 (홈 화면이므로)
            final recentOrders = historyController.orders.take(3).toList();

            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentOrders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return _buildOrderItem(context, order);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 빈 주문 상태 - 개선된 버전
  Widget _buildEmptyOrdersState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            '주문 내역이 없습니다',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '첫 주문을 시작해보세요!',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final mainController = Get.find<MainController>();
              mainController.changeTab(1); // 주문 탭으로 이동
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('주문하러 가기'),
          ),
        ],
      ),
    );
  }

  /// 주문 아이템 - 아이콘 제거된 버전 (텍스트만 유지)
  Widget _buildOrderItem(BuildContext context, OrderModel order) {
    return GestureDetector(
      onTap: () {
        // 주문 클릭 시 내역 탭으로 이동
        final mainController = Get.find<MainController>();
        mainController.changeTab(2); // 내역 탭으로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 판매자 텍스트 (아이콘 삭제)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '판매자',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 주문 상태 텍스트 (아이콘 삭제)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.displayText,
                      style: TextStyle(
                        color: order.status.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 두 번째 줄: 주문 날짜와 총 금액
              Row(
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    '${order.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // 주문 상품 목록
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} (${item.unit})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '${item.quantity}개',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${item.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 구분선
                const Divider(),
                const SizedBox(height: 8),
                // 총 금액
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 금액',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${order.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
