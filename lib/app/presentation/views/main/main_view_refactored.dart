import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/app_navigation.dart';
import '../../../core/theme/app_typography.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/buyer/order_controller.dart';
import '../../controllers/buyer/order_history_controller.dart';
import '../../controllers/buyer/seller_connect_controller.dart';
import '../../controllers/seller/seller_home_controller.dart';
import '../../controllers/seller/product_management_controller.dart';
import '../../controllers/seller/seller_orders_controller.dart';
import '../../controllers/seller/connection_requests_controller.dart';
import '../buyer/buyer_home_view_improved.dart';
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
            title: Text('로그아웃', style: AppTypography.headlineSmall),
            content: Text('정말 로그아웃하시겠습니까?', style: AppTypography.bodyMedium),
            actions: [
              AppComponents.textButton(
                text: '취소',
                onPressed: () => Navigator.of(context).pop(),
              ),
              AppComponents.primaryButton(
                text: '로그아웃',
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.signOut();
                },
              ),
            ],
          ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// MainViewRefactored - GetView 사용
class MainViewRefactored extends GetView<MainController> {
  const MainViewRefactored({super.key});

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
    Get.lazyPut(() => SellerOrdersController());
    Get.lazyPut(() => ConnectionRequestsController());

    print('=== MainViewRefactored: 모든 컨트롤러 등록 완료 ===');
  }

  Widget _buildBodySafe(BuildContext context) {
    // 컨트롤러 안전성 확인
    if (!Get.isRegistered<MainController>()) {
      return AppComponents.loadingIndicator(message: '컨트롤러를 초기화하는 중...');
    }

    // 사용자 정보가 없는 경우 로딩 화면
    if (controller.currentUser == null) {
      return AppComponents.loadingIndicator(message: '사용자 정보를 불러오는 중...');
    }

    try {
      if (controller.isBuyer) {
        return _buildBuyerContent();
      } else if (controller.isSeller) {
        return _buildSellerContent();
      } else {
        return AppComponents.emptyState(
          title: '사용자 역할을 확인할 수 없습니다',
          subtitle: '사용자 역할: ${controller.currentUser?.role}',
          icon: Icons.error_outline,
          action: AppComponents.primaryButton(
            text: '다시 로그인',
            onPressed: () => controller.signOut(),
            icon: Icons.refresh,
          ),
        );
      }
    } catch (e) {
      return AppComponents.emptyState(
        title: '화면 로딩 중 오류가 발생했습니다',
        subtitle: '오류: $e',
        icon: Icons.error_outline,
        action: AppComponents.primaryButton(
          text: '새로고침',
          onPressed: () => Get.forceAppUpdate(),
          icon: Icons.refresh,
        ),
      );
    }
  }

  Widget _buildBuyerContent() {
    return Obx(() {
      final currentIndex = controller.currentTabIndex.value.clamp(0, 3);

      // 각 탭별로 안전한 위젯 생성
      Widget getCurrentView() {
        switch (currentIndex) {
          case 0:
            return const BuyerHomeViewImproved();
          case 1:
            return const OrderTabView();
          case 2:
            return const OrderHistoryView();
          case 3:
            return const SellerConnectView();
          default:
            return const BuyerHomeViewImproved();
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
        return AppNavigation.bottomNavigationBar(
          currentIndex: controller.currentTabIndex.value,
          onDestinationSelected: (index) {
            // 안전한 탭 변경
            if (index >= 0 && index < 4) {
              controller.changeTabIndex(index);
            }
          },
          destinations: AppNavigation.buyerDestinations,
        );
      } else if (controller.isSeller) {
        return AppNavigation.bottomNavigationBar(
          currentIndex: controller.currentTabIndex.value,
          onDestinationSelected: (index) {
            // 안전한 탭 변경
            if (index >= 0 && index < 4) {
              controller.changeTabIndex(index);
            }
          },
          destinations: AppNavigation.sellerDestinations,
        );
      }
    } catch (e) {
      print('하단 네비게이션 렌더링 오류: $e');
    }

    return const SizedBox.shrink();
  }
}
