import 'package:get/get.dart';

import '../../core/state/global_state_controller.dart';
import '../../data/models/user_model.dart';
import '../../data/models/connection_model.dart';
import '../../routes/app_routes.dart';

/// 최적화된 메인 컨트롤러
/// GlobalStateController를 활용하여 중복 상태 관리 제거
class MainControllerOptimized extends GetxController {
  // 글로벌 상태 컨트롤러 참조
  GlobalStateController get _globalState => Get.find<GlobalStateController>();

  // 로컬 상태 (UI 전용)
  final RxInt currentTabIndex = 0.obs;
  final Rx<ConnectionModel?> activeConnection = Rx<ConnectionModel?>(null);

  // Getters - 글로벌 상태에서 가져오기
  UserModel? get currentUser => _globalState.currentUser;
  bool get isBuyer => _globalState.isBuyer;
  bool get isSeller => _globalState.isSeller;
  bool get isAuthenticated => _globalState.isAuthenticated;

  /// 활성 연결 설정 (구매자용)
  void setActiveConnection(ConnectionModel connection) {
    activeConnection.value = connection;
  }

  /// 현재 활성 연결 가져오기
  ConnectionModel? get currentConnection => activeConnection.value;

  /// 탭 변경
  void changeTab(int index) {
    // 유효한 탭 인덱스 확인
    if (index < 0) return;

    final maxIndex = isBuyer ? 3 : 3; // 구매자/판매자 모두 4개 탭 (0-3)
    if (index > maxIndex) return;

    currentTabIndex.value = index;
  }

  /// 탭 변경 (별칭)
  void changeTabIndex(int index) {
    changeTab(index);
  }

  /// 프로필 화면으로 이동
  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      // 글로벌 상태에서 로그아웃 처리됨
      await _globalState.authService.signOut();

      // 로컬 상태 클리어
      activeConnection.value = null;
      currentTabIndex.value = 0;
    } catch (e) {
      Get.snackbar(
        '오류',
        '로그아웃 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 특정 판매자와의 연결 찾기
  ConnectionModel? findConnectionWithSeller(String sellerId) {
    try {
      return _globalState.connections.firstWhere(
        (c) => c.sellerId == sellerId && c.status == ConnectionStatus.approved,
      );
    } catch (e) {
      return null;
    }
  }

  /// 현재 사용자의 역할에 따른 탭 정보 가져오기
  List<TabInfo> get availableTabs {
    if (isBuyer) {
      return [
        TabInfo(index: 0, title: '홈', icon: 'home'),
        TabInfo(index: 1, title: '주문', icon: 'shopping_cart'),
        TabInfo(index: 2, title: '내역', icon: 'history'),
        TabInfo(index: 3, title: '연결', icon: 'link'),
      ];
    } else if (isSeller) {
      return [
        TabInfo(index: 0, title: '홈', icon: 'dashboard'),
        TabInfo(index: 1, title: '상품', icon: 'inventory'),
        TabInfo(index: 2, title: '주문', icon: 'receipt'),
        TabInfo(index: 3, title: '고객', icon: 'people'),
      ];
    } else {
      return [];
    }
  }

  /// 현재 탭 정보 가져오기
  TabInfo? get currentTabInfo {
    final tabs = availableTabs;
    if (currentTabIndex.value < tabs.length) {
      return tabs[currentTabIndex.value];
    }
    return null;
  }

  /// 탭 변경 가능 여부 확인
  bool canChangeTab(int index) {
    return index >= 0 && index < availableTabs.length;
  }

  /// 홈 탭으로 이동
  void goToHome() {
    changeTab(0);
  }

  /// 이전 탭으로 이동
  void goToPreviousTab() {
    if (currentTabIndex.value > 0) {
      changeTab(currentTabIndex.value - 1);
    }
  }

  /// 다음 탭으로 이동
  void goToNextTab() {
    final maxIndex = availableTabs.length - 1;
    if (currentTabIndex.value < maxIndex) {
      changeTab(currentTabIndex.value + 1);
    }
  }

  /// 특정 기능으로 바로 이동하는 헬퍼 메서드들

  /// 주문 탭으로 이동 (구매자)
  void goToOrders() {
    if (isBuyer) changeTab(1);
  }

  /// 주문 내역 탭으로 이동 (구매자)
  void goToOrderHistory() {
    if (isBuyer) changeTab(2);
  }

  /// 연결 탭으로 이동 (구매자)
  void goToConnections() {
    if (isBuyer) changeTab(3);
  }

  /// 상품 관리 탭으로 이동 (판매자)
  void goToProductManagement() {
    if (isSeller) changeTab(1);
  }

  /// 주문 관리 탭으로 이동 (판매자)
  void goToOrderManagement() {
    if (isSeller) changeTab(2);
  }

  /// 고객 관리 탭으로 이동 (판매자)
  void goToCustomerManagement() {
    if (isSeller) changeTab(3);
  }

  /// 앱 상태 요약 정보
  AppStateSummary get appStateSummary {
    return AppStateSummary(
      isAuthenticated: isAuthenticated,
      userRole: currentUser?.role,
      userName: currentUser?.displayName ?? '',
      currentTab: currentTabIndex.value,
      hasActiveConnection: activeConnection.value != null,
      connectionCount: _globalState.connections.length,
      orderCount: _globalState.orders.length,
    );
  }

  @override
  void onClose() {
    // 로컬 상태만 정리 (글로벌 상태는 유지)
    activeConnection.value = null;
    super.onClose();
  }
}

/// 탭 정보 클래스
class TabInfo {
  final int index;
  final String title;
  final String icon;

  const TabInfo({required this.index, required this.title, required this.icon});
}

/// 앱 상태 요약 클래스
class AppStateSummary {
  final bool isAuthenticated;
  final UserRole? userRole;
  final String userName;
  final int currentTab;
  final bool hasActiveConnection;
  final int connectionCount;
  final int orderCount;

  const AppStateSummary({
    required this.isAuthenticated,
    this.userRole,
    required this.userName,
    required this.currentTab,
    required this.hasActiveConnection,
    required this.connectionCount,
    required this.orderCount,
  });

  @override
  String toString() {
    return 'AppStateSummary(authenticated: $isAuthenticated, role: $userRole, user: $userName, tab: $currentTab, connections: $connectionCount, orders: $orderCount)';
  }
}
