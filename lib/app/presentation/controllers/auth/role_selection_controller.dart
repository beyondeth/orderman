import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class RoleSelectionController extends GetxController {
  // Reactive variables
  final Rx<UserRole?> selectedRole = Rx<UserRole?>(null);

  // Select role
  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  // Continue to profile setup
  void continueToProfileSetup() {
    if (selectedRole.value == null) {
      Get.snackbar(
        '역할 선택',
        '역할을 선택해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 선택된 역할을 프로필 설정 화면으로 전달
    Get.toNamed(
      AppRoutes.profileSetup,
      arguments: {'role': selectedRole.value},
    );
  }

  // Get role description
  String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return '식자재를 주문하는 사업자\n(식당, 카페 등)';
      case UserRole.seller:
        return '식자재를 판매하는 사업자\n(유통업체, 도매업체)';
    }
  }

  // Get role icon
  String getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return '🍽️';
      case UserRole.seller:
        return '📦';
    }
  }
}
