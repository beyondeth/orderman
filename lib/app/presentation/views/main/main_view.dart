import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/buyer/order_controller.dart';
import '../../controllers/buyer/order_history_controller.dart';
import '../../controllers/buyer/seller_connect_controller.dart';
import '../../controllers/seller/seller_home_controller.dart';
import '../../controllers/seller/product_management_controller.dart';
import '../../controllers/seller/seller_orders_controller.dart';
import '../../controllers/seller/connection_requests_controller.dart';
import '../buyer/buyer_home_view.dart';
import '../buyer/order_tab_view.dart';
import '../buyer/order_history_view.dart';
import '../buyer/seller_connect_view.dart';
import '../seller/seller_home_view.dart';
import '../seller/product_management_view.dart';
import '../seller/seller_orders_view.dart';
import '../seller/connection_requests_view.dart';

// 커스텀 AppBar 위젯 - PreferredSizeWidget 구현
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Obx(() {
      // 사용자 정보가 없는 경우 기본 AppBar
      if (controller.currentUser == null) {
        return AppBar(title: const Text('Order Market'), centerTitle: true);
      }

      return AppBar(
        title: Text(_getAppBarTitle(controller)),
        centerTitle: true,
        actions: _buildActions(context, controller),
      );
    });
  }

  String _getAppBarTitle(MainController controller) {
    if (controller.isBuyer) {
      return _getBuyerTitle(controller.currentTabIndex.value);
    } else if (controller.isSeller) {
      return _getSellerTitle(controller.currentTabIndex.value);
    }
    return 'Order Market';
  }

  String _getBuyerTitle(int index) {
    const titles = ['홈', '주문', '주문 내역', '판매자 연결'];
    return index < titles.length ? titles[index] : '홈';
  }

  String _getSellerTitle(int index) {
    const titles = ['홈', '상품 관리', '주문 관리', '고객 관리'];
    return index < titles.length ? titles[index] : '홈';
  }

  List<Widget> _buildActions(BuildContext context, MainController controller) {
    return [
      IconButton(
        onPressed: () => Get.toNamed('/profile'),
        icon: const Icon(Icons.account_circle_outlined),
        tooltip: '프로필',
      ),
      PopupMenuButton<String>(
        onSelected: (value) => _handleMenuSelection(value, context, controller),
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('프로필'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('설정'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('로그아웃', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
      ),
    ];
  }

  void _handleMenuSelection(
    String value,
    BuildContext context,
    MainController controller,
  ) {
    switch (value) {
      case 'profile':
        Get.toNamed('/profile');
        break;
      case 'settings':
        Get.toNamed('/settings');
        break;
      case 'logout':
        _showLogoutDialog(context, controller);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context, MainController controller) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '로그아웃',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '정말 로그아웃하시겠습니까?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            backgroundColor: AppColors.surface,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '취소',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// MainViewRefactored - GetView 사용
class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // 필요한 컨트롤러들을 미리 등록
    _initializeControllers();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Obx(() => _buildBodySafe(context)),
      bottomNavigationBar: Obx(() => _buildBottomNavigationSafe(context)),
    );
  }

  void _initializeControllers() {
    // 컨트롤러 등록을 lazyPut으로 최적화
    Get.lazyPut(() => BuyerHomeController());
    Get.lazyPut(() => SellerHomeController());
    Get.lazyPut(() => OrderController());
    Get.lazyPut(() => OrderHistoryController());
    Get.lazyPut(() => SellerConnectController());
    Get.lazyPut(() => ProductManagementController());
    
    // SellerOrdersController를 즉시 등록 (주문탭에서 바로 사용하기 위해)
    if (!Get.isRegistered<SellerOrdersController>()) {
      Get.put(SellerOrdersController());
      print('=== SellerOrdersController 등록 완료 ===');
    }
    
    Get.lazyPut(() => ConnectionRequestsController());

    print('=== MainView: 모든 컨트롤러 등록 완료 ===');
  }

  Widget _buildBodySafe(BuildContext context) {
    // 컨트롤러 안전성 확인
    if (!Get.isRegistered<MainController>()) {
      return _buildLoadingState('컨트롤러를 초기화하는 중...');
    }

    // 사용자 정보가 없는 경우 로딩 화면
    if (controller.currentUser == null) {
      return _buildLoadingState('사용자 정보를 불러오는 중...');
    }

    try {
      if (controller.isBuyer) {
        return _buildBuyerContent();
      } else if (controller.isSeller) {
        return _buildSellerContent();
      } else {
        return _buildErrorState(
          '사용자 역할을 확인할 수 없습니다',
          '사용자 역할: ${controller.currentUser?.role}',
          Icons.error_outline,
          '다시 로그인',
          () => controller.signOut(),
        );
      }
    } catch (e) {
      return _buildErrorState(
        '화면 로딩 중 오류가 발생했습니다',
        '오류: $e',
        Icons.error_outline,
        '새로고침',
        () => Get.forceAppUpdate(),
      );
    }
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              Get.context!,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String title,
    String subtitle,
    IconData icon,
    String buttonText,
    VoidCallback onPressed,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                Get.context!,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerContent() {
    return Obx(() {
      final currentIndex = controller.currentTabIndex.value.clamp(0, 3);

      // 각 탭별로 안전한 위젯 생성
      Widget getCurrentView() {
        switch (currentIndex) {
          case 0:
            return const BuyerHomeView();
          case 1:
            return const OrderTabView();
          case 2:
            return const OrderHistoryView();
          case 3:
            return const SellerConnectView();
          default:
            return const BuyerHomeView();
        }
      }

      return Container(
        key: ValueKey('buyer_content_$currentIndex'),
        child: getCurrentView(),
      );
    });
  }

  Widget _buildSellerContent() {
    return Obx(() {
      final currentIndex = controller.currentTabIndex.value.clamp(0, 3);

      // 각 탭별로 안전한 위젯 생성
      Widget getCurrentView() {
        switch (currentIndex) {
          case 0:
            return const SellerHomeView();
          case 1:
            return const ProductManagementView();
          case 2:
            return const SellerOrdersView();
          case 3:
            return const ConnectionRequestsView();
          default:
            return const SellerHomeView();
        }
      }

      return Container(
        key: ValueKey('seller_content_$currentIndex'),
        child: getCurrentView(),
      );
    });
  }

  Widget _buildBottomNavigationSafe(BuildContext context) {
    // 컨트롤러 안전성 확인
    if (!Get.isRegistered<MainController>()) {
      return const SizedBox.shrink();
    }

    // 사용자 정보 확인
    if (controller.currentUser == null) {
      return const SizedBox.shrink();
    }

    try {
      if (controller.isBuyer) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: AppColors.surface,
          elevation: 8,
          currentIndex: controller.currentTabIndex.value,
          onTap: (index) {
            if (index >= 0 && index < 4) {
              controller.changeTabIndex(index);
            }
          },
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: '주문',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: '내역',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: '연결',
            ),
          ],
        );
      } else if (controller.isSeller) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: AppColors.surface,
          elevation: 8,
          currentIndex: controller.currentTabIndex.value,
          onTap: (index) {
            if (index >= 0 && index < 4) {
              controller.changeTabIndex(index);
            }
          },
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_outlined),
              activeIcon: Icon(Icons.inventory),
              label: '상품',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: '주문',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: '연결',
            ),
          ],
        );
      }
    } catch (e) {
      print('하단 네비게이션 렌더링 오류: $e');
    }

    return const SizedBox.shrink();
  }
}
