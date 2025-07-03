import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/connection_model.dart';
import '../../routes/app_routes.dart';

class MainController extends GetxController {
  // Services
  AuthService get _authService => Get.find<AuthService>();

  // Reactive variables
  final RxInt currentTabIndex = 0.obs;
  final Rx<ConnectionModel?> activeConnection = Rx<ConnectionModel?>(null);

  // Getters
  UserModel? get currentUser => _authService.userModel;
  bool get isBuyer => currentUser?.role == UserRole.buyer;
  bool get isSeller => currentUser?.role == UserRole.seller;

  // Set active connection for buyer
  void setActiveConnection(ConnectionModel connection) {
    activeConnection.value = connection;
    print('=== 🔗 MainController: Active connection set: ${connection.sellerName} ===');
  }

  // Get current active connection
  ConnectionModel? get currentConnection => activeConnection.value;

  // 탭 변경
  void changeTab(int index) {
    try {
      // 유효한 인덱스 범위 확인
      if (index < 0 || index > 3) {
        print('=== MainController: Invalid tab index: $index ===');
        return;
      }
      
      print('=== MainController: Changing tab from ${currentTabIndex.value} to $index ===');
      currentTabIndex.value = index;
    } catch (e) {
      print('=== MainController: Error changing tab: $e ===');
    }
  }

  // 탭 변경 (별칭)
  void changeTabIndex(int index) {
    changeTab(index);
  }

  // 프로필 화면으로 이동
  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // Clear active connection on sign out
      activeConnection.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('=== Sign out error: $e ===');
      Get.snackbar('오류', '로그아웃 중 오류가 발생했습니다.');
    }
  }
}
