import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class ProfileSetupController extends GetxController {
  final AuthService _authService = AuthService.instance;

  // Form controllers
  final displayNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  late final UserRole selectedRole;

  @override
  void onInit() {
    super.onInit();

    // Get role from arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    selectedRole = arguments?['role'] ?? UserRole.buyer;

    // Pre-fill existing data if available
    _prefillExistingData();
  }

  void _prefillExistingData() {
    // Firebase Auth에서 displayName 가져오기
    if (_authService.firebaseUser?.displayName != null) {
      displayNameController.text = _authService.firebaseUser!.displayName!;
    }

    // 기존 UserModel에서 데이터 가져오기
    final userModel = _authService.userModel;
    if (userModel != null) {
      print('=== 기존 프로필 데이터로 미리 채우기 ===');
      
      if (userModel.displayName.isNotEmpty) {
        displayNameController.text = userModel.displayName;
      }
      
      if (userModel.phoneNumber?.isNotEmpty == true) {
        phoneNumberController.text = userModel.phoneNumber!;
      }
      
      if (userModel.businessName?.isNotEmpty == true) {
        businessNameController.text = userModel.businessName!;
      }
      
      print('displayName: ${displayNameController.text}');
      print('phoneNumber: ${phoneNumberController.text}');
      print('businessName: ${businessNameController.text}');
    }
  }

  @override
  void onClose() {
    displayNameController.dispose();
    phoneNumberController.dispose();
    businessNameController.dispose();
    super.onClose();
  }

  // Display name validation
  String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요.';
    }
    if (value.trim().length < 2) {
      return '이름은 2자 이상이어야 합니다.';
    }
    return null;
  }

  // Phone number validation
  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return '올바른 전화번호를 입력해주세요.';
    }
    return null;
  }

  // Business name validation
  String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length < 2) {
      return '사업장명은 2자 이상이어야 합니다.';
    }
    return null;
  }

  // Complete profile setup
  Future<void> completeSetup() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      print('=== 프로필 설정 시작 ===');
      print('displayName: ${displayNameController.text.trim()}');
      print('role: ${selectedRole.name}');
      print('phoneNumber: ${phoneNumberController.text.trim()}');
      print('businessName: ${businessNameController.text.trim()}');

      final success = await _authService.createUserProfile(
        displayName: displayNameController.text.trim(),
        role: selectedRole,
        phoneNumber:
            phoneNumberController.text.trim().isEmpty
                ? null
                : phoneNumberController.text.trim(),
        businessName:
            businessNameController.text.trim().isEmpty
                ? null
                : businessNameController.text.trim(),
      );

      if (success != null) {
        print('=== 프로필 생성 성공 - 메인 화면으로 이동 ===');
        
        // 성공 메시지 표시
        Get.snackbar(
          '프로필 설정 완료',
          '프로필이 성공적으로 설정되었습니다.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // 잠시 대기 후 메인 화면으로 이동
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToHome();
      } else {
        print('=== 프로필 생성 실패 ===');
        Get.snackbar(
          '프로필 설정 실패',
          '프로필 설정 중 오류가 발생했습니다. 다시 시도해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('=== Profile setup error: $e ===');
      Get.snackbar(
        '오류 발생',
        '네트워크 연결을 확인하고 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to home - 메인 화면으로 통일
  void _navigateToHome() {
    print('=== 메인 화면으로 이동 (역할: ${selectedRole.name}) ===');
    Get.offAllNamed(AppRoutes.main);
  }

  // Get role display name
  String get roleDisplayName {
    switch (selectedRole) {
      case UserRole.buyer:
        return '구매자';
      case UserRole.seller:
        return '판매자';
    }
  }

  // Get role description
  String get roleDescription {
    switch (selectedRole) {
      case UserRole.buyer:
        return '식자재를 주문하는 사업자';
      case UserRole.seller:
        return '식자재를 판매하는 사업자';
    }
  }
}
