import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // 필요한 컨트롤러들을 미리 등록
    Get.put(BuyerHomeController());
    Get.put(SellerHomeController());
    
    // 구매자용 컨트롤러들
    if (!Get.isRegistered<OrderController>()) {
      Get.put(OrderController());
    }
    if (!Get.isRegistered<OrderHistoryController>()) {
      Get.put(OrderHistoryController());
    }
    if (!Get.isRegistered<SellerConnectController>()) {
      Get.put(SellerConnectController());
    }
    
    // 판매자용 컨트롤러들
    if (!Get.isRegistered<ProductManagementController>()) {
      Get.put(ProductManagementController());
    }
    if (!Get.isRegistered<SellerOrdersController>()) {
      Get.put(SellerOrdersController());
    }
    if (!Get.isRegistered<ConnectionRequestsController>()) {
      Get.put(ConnectionRequestsController());
    }
    
    return Scaffold(
      appBar: _buildFixedAppBar(context),
      body: Obx(() {
        print('=== MainView - Current User: ${controller.currentUser?.displayName} ===');
        print('=== MainView - User Role: ${controller.currentUser?.role} ===');
        print('=== MainView - Is Buyer: ${controller.isBuyer} ===');
        print('=== MainView - Is Seller: ${controller.isSeller} ===');
        print('=== MainView - Current Tab: ${controller.currentTabIndex.value} ===');
        
        // 사용자 정보가 없는 경우 로딩 화면
        if (controller.currentUser == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('사용자 정보를 불러오는 중...'),
              ],
            ),
          );
        }
        
        if (controller.isBuyer) {
          print('=== 구매자 화면 렌더링 ===');
          return _buildBuyerContent();
        } else if (controller.isSeller) {
          print('=== 판매자 화면 렌더링 ===');
          return _buildSellerContent();
        } else {
          // 역할이 명확하지 않은 경우
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('사용자 역할을 확인할 수 없습니다: ${controller.currentUser?.role}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.signOut(),
                  child: const Text('다시 로그인'),
                ),
              ],
            ),
          );
        }
      }),
      bottomNavigationBar: Obx(() {
        print('=== BottomNav - Is Buyer: ${controller.isBuyer} ===');
        print('=== BottomNav - Is Seller: ${controller.isSeller} ===');
        return _buildBottomNavigationBar(context);
      }),
    );
  }

  Widget _buildBuyerContent() {
    switch (controller.currentTabIndex.value) {
      case 0: // 홈
        return const BuyerHomeView();
      case 1: // 주문
        return const OrderTabView();
      case 2: // 내역
        return const OrderHistoryView();
      case 3: // 연결
        return const SellerConnectView();
      default:
        return const BuyerHomeView();
    }
  }

  Widget _buildSellerContent() {
    switch (controller.currentTabIndex.value) {
      case 0: // 홈
        return const SellerHomeView();
      case 1: // 상품
        return const ProductManagementView();
      case 2: // 주문
        return const SellerOrdersView();
      case 3: // 연결
        return const ConnectionRequestsView();
      default:
        return const SellerHomeView();
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    // 사용자 정보가 없으면 빈 컨테이너 반환
    if (controller.currentUser == null) {
      print('=== BottomNav - No user, returning empty container ===');
      return const SizedBox.shrink();
    }
    
    if (controller.isBuyer) {
      print('=== BottomNav - Building buyer navigation ===');
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.changeTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '주문',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: '내역',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '연결',
          ),
        ],
      );
    } else if (controller.isSeller) {
      print('=== BottomNav - Building seller navigation ===');
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.changeTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: '상품',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: '주문',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '연결',
          ),
        ],
      );
    } else {
      print('=== BottomNav - Unknown user type, returning empty container ===');
      return const SizedBox.shrink();
    }
  }

  PreferredSizeWidget _buildFixedAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        // 사용자 정보가 없는 경우 기본 AppBar
        if (controller.currentUser == null) {
          return AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text('로딩 중...'),
          );
        }

        if (controller.isBuyer) {
          return AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '구매자',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentUser?.displayName ?? '사용자',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (controller.currentUser?.businessName?.isNotEmpty == true)
                        Text(
                          controller.currentUser!.businessName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      _goToProfile();
                      break;
                    case 'settings':
                      _goToSettings();
                      break;
                    case 'logout':
                      _showLogoutDialog(context);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('프로필'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('설정'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('로그아웃', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (controller.isSeller) {
          return AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '판매자',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentUser?.displayName ?? '사용자',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (controller.currentUser?.businessName?.isNotEmpty == true)
                        Text(
                          controller.currentUser!.businessName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      _goToProfile();
                      break;
                    case 'settings':
                      _goToSettings();
                      break;
                    case 'logout':
                      _showLogoutDialog(context);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('프로필'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('설정'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('로그아웃', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text('오류'),
          );
        }
      }),
    );
  }

  void _goToProfile() {
    // 프로필 화면으로 이동 로직
    Get.snackbar('알림', '프로필 화면으로 이동합니다.');
  }

  void _goToSettings() {
    // 설정 화면으로 이동 로직
    Get.snackbar('알림', '설정 화면으로 이동합니다.');
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.signOut();
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
